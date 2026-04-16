import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';

import '../../data/datasources/local/isar_provider.dart';
import '../../data/services/ref_counted_invoice_service.dart';

/// Cancel-Orphan Protocol — Dialog Lifecycle for Normalized Invoice Architecture
///
/// Uses int? transientImageId (InvoiceImage PK) instead of string paths.
/// RefCountedInvoiceService handles deduplication, ref counting, and file I/O.
mixin InvoiceDialogLifecycle<T extends StatefulWidget> on State<T> {
  late RefCountedInvoiceService _invoiceService;

  /// Tracks the current InvoiceImage ID in dialog state.
  int? transientImageId;

  /// The ID that existed BEFORE this dialog session.
  int? _originalImageId;
  bool _didSave = false;

  /// Call in initState with the Isar instance and existing record's invoiceImageId.
  void initInvoiceLifecycle({required Isar isar, int? initialImageId}) {
    _invoiceService = RefCountedInvoiceService(isar);
    _originalImageId = initialImageId;
    transientImageId = initialImageId;
    _didSave = false;
  }

  /// Callback when user taps the pick button.
  /// Shows bottom sheet to choose Camera or Gallery.
  Future<void> pickInvoice() async {
    final selectedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selectedSource == null) return; // User dismissed sheet

    // Phantom Guard: detach old transient BEFORE new pick
    final currentId = transientImageId;
    if (currentId != null && currentId != _originalImageId) {
      debugPrint('[PHANTOM GUARD] Pre-detaching old transient: $currentId');
      await _invoiceService.detachOrDelete(currentId);
      debugPrint('[PHANTOM GUARD] Old transient detached. File leak prevented.');
      setState(() {
        transientImageId = null;
      });
    }

    // Pick with selected source
    final newId = await _invoiceService.pickAndAttach(
      source: selectedSource,
    );

    if (newId != null) {
      debugPrint('[DEDUP] pickAndAttach returned ID: $newId');
      debugPrint('[PHANTOM GUARD] New transientImageId set to: $newId');
      setState(() {
        transientImageId = newId;
      });
    }
  }

  /// Call in dispose() — handles orphan cleanup ONLY if save was not confirmed.
  Future<void> disposeInvoiceLifecycle() async {
    if (_didSave) {
      debugPrint('[LIFECYCLE] dispose: save confirmed, skipping cleanup');
      return;
    }

    final currentId = transientImageId;
    if (currentId != null && currentId != _originalImageId) {
      debugPrint('[LIFECYCLE] dispose: orphan cleanup for ID $currentId');
      await _invoiceService.detachOrDelete(currentId);
    }
  }

  /// Mark save as confirmed.
  String? finalizeInvoicePath() {
    // Kept for backward compat — returns null, ID is used instead
    _didSave = true;
    debugPrint('[LIFECYCLE] finalize: _didSave=true, transientImageId=$transientImageId');
    return null;
  }

  /// Mark save as confirmed (new ID-based method).
  int? finalizeInvoiceId() {
    _didSave = true;
    debugPrint('[LIFECYCLE] finalize: _didSave=true, returning ID=$transientImageId');
    return transientImageId;
  }

  /// Revert save confirmation if Isar write fails.
  void revertSaveConfirmation() {
    debugPrint('[LIFECYCLE] reverting _didSave to false');
    _didSave = false;
  }

  /// Cleanup old image AFTER successful Isar save.
  Future<void> cleanupOldImage() async {
    final originalId = _originalImageId;
    final currentId = transientImageId;
    if (originalId != null && originalId != currentId) {
      debugPrint('[REF_COUNT CHANGE] cleanupOldImage: detaching $originalId');
      await _invoiceService.detachOrDelete(originalId);
    }
  }

  /// Get the File for the current transient image.
  Future<File?> resolveCurrentInvoiceFile() async {
    final currentId = transientImageId;
    if (currentId == null) return null;
    return _invoiceService.getFile(currentId);
  }

  /// Widget to embed in dialog body.
  Widget buildInvoicePicker() {
    return InvoicePickerWidget(
      imageId: transientImageId,
      onPickPressed: pickInvoice,
      onRemovePressed: () async {
        final currentId = transientImageId;
        if (currentId != null && currentId != _originalImageId) {
          await _invoiceService.detachOrDelete(currentId);
        }
        setState(() {
          transientImageId = null;
        });
      },
    );
  }
}

/// Standalone invoice picker widget for embedding in dialogs.
class InvoicePickerWidget extends ConsumerWidget {
  final int? imageId;
  final VoidCallback onPickPressed;
  final VoidCallback onRemovePressed;

  const InvoicePickerWidget({
    super.key,
    required this.imageId,
    required this.onPickPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Photo',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (imageId == null)
          _buildEmptyState(theme)
        else
          _buildFilledState(context, ref, theme),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPickPressed,
            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
            label: const Text('Attach Invoice'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilledState(BuildContext context, WidgetRef ref, ThemeData theme) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Real thumbnail via FutureBuilder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<File?>(
              future: _resolveThumbnail(ref),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.primaryContainer,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final file = snapshot.data;
                if (file == null) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.errorContainer,
                    child: Icon(Icons.broken_image, color: theme.colorScheme.onErrorContainer),
                  );
                }
                return Image.file(
                  file,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          // Remove button
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemovePressed,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14, color: theme.colorScheme.onError),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File?> _resolveThumbnail(WidgetRef ref) async {
    final currentId = imageId;
    if (currentId == null) return null;
    final isar = ref.read(isarProvider);
    final service = RefCountedInvoiceService(isar);
    return service.getFile(currentId);
  }
}
