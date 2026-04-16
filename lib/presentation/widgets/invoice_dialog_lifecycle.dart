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
  String? _originalImagePath;
  bool _didSave = false; // Track whether save was confirmed

  /// Call in initState with the existing record's image path (or null for new).
  void initInvoiceLifecycle({String? initialPath}) {
    _originalImagePath = initialPath;
    transientImagePath = initialPath;
    _didSave = false;
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

  /// Call in dispose() — handles orphan cleanup ONLY if save was not confirmed.
  void disposeInvoiceLifecycle() {
    // If save was confirmed, do NOT delete — cleanup happens in cleanupOldImage()
    if (_didSave) {
      debugPrint('[INVOICE TRACE] DialogLifecycle — dispose: save confirmed, skipping cleanup');
      return;
    }

    if (transientImagePath == null && _originalImagePath != null) {
      // User removed image but cancelled — original still exists, no action
      return;
    }

    if (transientImagePath != null &&
        transientImagePath != _originalImagePath) {
      // Dialog dismissed WITHOUT saving — delete orphan
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

    // Mark save as confirmed — dispose will skip orphan cleanup
    _didSave = true;

    debugPrint('[INVOICE TRACE] DialogLifecycle — returning: $transientImagePath');
    return transientImagePath;
  }

  /// Revert save confirmation if Isar write fails.
  /// Dispose will then correctly clean up the orphaned file.
  void revertSaveConfirmation() {
    debugPrint('[INVOICE TRACE] DialogLifecycle — reverting _didSave to false (DB write failed)');
    _didSave = false;
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
