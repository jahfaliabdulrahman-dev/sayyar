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
    setState(() {
      transientImagePath = newPath;
    });
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
      // No deletion needed, original still exists.
      return;
    }

    if (transientImagePath != null &&
        transientImagePath != _originalImagePath) {
      // Scenario 1 or 2: New image captured but dialog dismissed
      // Delete the orphan
      _invoiceStorage.deleteInvoice(transientImagePath!);
    }
  }

  /// Call this in your save/confirm handler BEFORE saving to Isar.
  ///
  /// Returns the final path to store in MaintenanceRecord.
  /// Handles old image cleanup if the user replaced the invoice.
  String? finalizeInvoicePath() {
    if (transientImagePath != _originalImagePath) {
      // New image was set — delete old one if it existed
      if (_originalImagePath != null) {
        _invoiceStorage.deleteInvoice(_originalImagePath!);
      }
    }

    // transientImagePath is now the confirmed path
    // (or null if user removed the invoice)
    return transientImagePath;
  }

  /// Widget to embed in your dialog body:
  Widget buildInvoicePicker() {
    return InvoiceImagePickerWidget(
      currentImagePath: transientImagePath,
      onImageChanged: onInvoiceImageChanged,
    );
  }
}
