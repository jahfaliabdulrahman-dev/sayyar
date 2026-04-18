import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/local_invoice_storage_service.dart';
import '../providers/settings_provider.dart';

/// Reusable invoice image picker with two states:
/// - Empty: [Camera] [Gallery] buttons
/// - Filled: 80x80 thumbnail with fullscreen tap + remove overlay
///
/// Lifecycle: Calls [onImageChanged] with new relative path or null.
/// Parent dialog MUST handle orphan cleanup on dismiss — see Cancel-Orphan protocol.
class InvoiceImagePickerWidget extends ConsumerStatefulWidget {
  final String? currentImagePath;
  final ValueChanged<String?> onImageChanged;

  const InvoiceImagePickerWidget({
    super.key,
    required this.currentImagePath,
    required this.onImageChanged,
  });

  @override
  ConsumerState<InvoiceImagePickerWidget> createState() =>
      _InvoiceImagePickerWidgetState();
}

class _InvoiceImagePickerWidgetState extends ConsumerState<InvoiceImagePickerWidget> {
  final _storage = LocalInvoiceStorageService();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    final relativePath = await _storage.captureAndSaveInvoice(source: source);

    debugPrint('[INVOICE TRACE] Picker — captureAndSaveInvoice returned: $relativePath');

    if (mounted) {
      setState(() => _isLoading = false);

      if (relativePath != null) {
        // Delete old image if replacing (not null = replacing existing)
        if (widget.currentImagePath != null) {
          await _storage.deleteInvoice(widget.currentImagePath!);
        }
        debugPrint('[INVOICE TRACE] Picker — calling onImageChanged with: $relativePath');
        widget.onImageChanged(relativePath);
      } else {
        debugPrint('[INVOICE TRACE] Picker — user cancelled or capture failed');
      }
    }
  }

  void _removeImage() async {
    // Deletion responsibility falls to parent dialog's orphan cleanup.
    // Here we just notify the parent to clear the path.
    widget.onImageChanged(null);
  }

  void _openFullscreen() {
    showDialog(
      context: context,
      builder: (_) =>
          InvoiceFullscreenViewer(imagePath: widget.currentImagePath!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = ref.watch(settingsProvider).t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          t('invoice_photo'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // State switch
        if (_isLoading)
          _buildLoadingState(theme)
        else if (widget.currentImagePath == null)
          _buildEmptyState(theme)
        else
          _buildFilledState(theme),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final t = ref.watch(settingsProvider).t;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: Text(t('camera')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(t('gallery')),
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

  Widget _buildFilledState(ThemeData theme) {
    return FutureBuilder<File?>(
      future: _storage.resolveInvoiceFile(widget.currentImagePath),
      builder: (context, snapshot) {
        final file = snapshot.data;

        if (file == null) {
          // Orphaned reference — file was deleted externally
          return _buildEmptyState(theme);
        }

        return SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Thumbnail
              GestureDetector(
                onTap: _openFullscreen,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    file,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),

              // Remove button
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fullscreen image viewer with pinch-to-zoom.
class InvoiceFullscreenViewer extends ConsumerWidget {
  final String imagePath;

  const InvoiceFullscreenViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(settingsProvider).t;
    final storage = LocalInvoiceStorageService();

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: FutureBuilder<File?>(
        future: storage.resolveInvoiceFile(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final file = snapshot.data;
          if (file == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image, color: Colors.white54, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    t('image_not_found'),
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t('close')),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Zoomable image
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(file),
                ),
              ),

              // Close button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
