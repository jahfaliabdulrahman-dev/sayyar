/// CANCEL-ORPHAN PROTOCOL — Dialog Lifecycle Integration
///
/// This snippet shows how to integrate InvoiceImagePickerWidget into
/// Add/Edit Record dialogs with proper orphan cleanup.
///
/// KEY RULE: If the user captures an image but dismisses without saving,
/// the transient image MUST be deleted to prevent sandbox orphans.

import 'package:flutter/material.dart';

import '../../data/services/local_invoice_storage_service.dart';
import '../widgets/invoice_image_picker_widget.dart';

/// Mixin for dialogs that contain an InvoiceImagePickerWidget.
///
/// Usage:
///   class _AddRecordDialogState extends State<AddRecordDialog>
///       with InvoiceDialogLifecycle {
///
///     @override
///     void initState() {
///       super.initState();
///       initInvoiceLifecycle(initialPath: null);
///     }
///
///     @override
///     void dispose() {
///       disposeInvoiceLifecycle(); // ← Orphan cleanup here
///       super.dispose();
///     }
///
///     // In save handler:
///     // record.invoiceImagePath = transientImagePath;
///   }
mixin InvoiceDialogLifecycle<T extends StatefulWidget> on State<T> {
  final LocalInvoiceStorageService _invoiceStorage =
      LocalInvoiceStorageService();

  /// Tracks the current image path in dialog state.
  /// - null = no image attached
  /// - non-null = image captured (transient until save confirms)
  String? transientImagePath;

  /// The path that existed BEFORE this dialog session.
  /// Used to detect "replaced" images that also need cleanup.
  String? _originalImagePath;

  /// Call in initState with the existing record's image path (or null for new).
  void initInvoiceLifecycle({String? initialPath}) {
    _originalImagePath = initialPath;
    transientImagePath = initialPath;
  }

  /// Callback for InvoiceImagePickerWidget.onImageChanged
  void onInvoiceImageChanged(String? newPath) {
    debugPrint('[INVOICE TRACE] DialogLifecycle — onInvoiceImageChanged called with: $newPath');
    debugPrint('[INVOICE TRACE] DialogLifecycle — previous transientImagePath: $transientImagePath');
    setState(() {
      transientImagePath = newPath;
    });
    debugPrint('[INVOICE TRACE] DialogLifecycle — transientImagePath is now: $transientImagePath');
  }

  /// Call in dispose() — handles orphan cleanup.
  ///
  /// Three scenarios:
  /// 1. User captured image, cancelled dialog → DELETE transient
  /// 2. User replaced image, cancelled dialog → DELETE new, KEEP original
  /// 3. User removed image, cancelled dialog → KEEP original (no action)
  void disposeInvoiceLifecycle() {
    if (transientImagePath == null && _originalImagePath != null) {
      // Scenario 3: User removed image but cancelled — restore original
      return;
    }

    if (transientImagePath != null &&
        transientImagePath != _originalImagePath) {
      // Scenario 1 or 2: New image captured but dialog dismissed
      // Delete the orphan
      debugPrint('[INVOICE TRACE] DialogLifecycle — dispose: orphan cleanup $transientImagePath');
      _invoiceStorage.deleteInvoice(transientImagePath!);
    }

    // Forensic: log state on dispose
    debugPrint('[INVOICE TRACE] DialogLifecycle — dispose: transientImagePath=$transientImagePath, original=$_originalImagePath');
  }

  /// Call this in your save/confirm handler BEFORE saving to Isar.
  ///
  /// Returns the final path to store in MaintenanceRecord.
  /// Handles old image cleanup if the user replaced the invoice.
  String? finalizeInvoicePath() {
    debugPrint('[INVOICE TRACE] DialogLifecycle — finalizeInvoicePath() called');
    debugPrint('[INVOICE TRACE] DialogLifecycle — transientImagePath: $transientImagePath');
    debugPrint('[INVOICE TRACE] DialogLifecycle — _originalImagePath: $_originalImagePath');

    // NOTE: Do NOT delete old image here — the Isar update hasn't committed yet.
    // The detail page may still read the old record with the old path.
    // Old image cleanup happens in cleanupOldImage() AFTER Isar save succeeds.

    debugPrint('[INVOICE TRACE] DialogLifecycle — returning: $transientImagePath');
    return transientImagePath;
  }

  /// Call AFTER Isar save succeeds to delete the old image file.
  /// Must not be called before the new record is committed to the database.
  void cleanupOldImage() {
    if (transientImagePath != _originalImagePath && _originalImagePath != null) {
      debugPrint('[INVOICE TRACE] DialogLifecycle — cleanup: deleting old image: $_originalImagePath');
      _invoiceStorage.deleteInvoice(_originalImagePath!);
    }
  }

  /// Widget to embed in your dialog body:
  Widget buildInvoicePicker() {
    return InvoiceImagePickerWidget(
      currentImagePath: transientImagePath,
      onImageChanged: onInvoiceImageChanged,
    );
  }
}
