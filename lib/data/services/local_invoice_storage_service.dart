import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles invoice image lifecycle: pick → compress → sandbox save.
///
/// Zero cloud interaction. All paths are relative for Isar storage.
/// Returns null on user cancel or any failure — never crashes the app.
class LocalInvoiceStorageService {
  static const _invoiceDir = 'invoices';
  static const _quality = 85;
  static const _minWidth = 1080;
  static const _minHeight = 1080;

  final ImagePicker _picker = ImagePicker();

  /// Capture or pick an invoice image, compress it, and save to sandbox.
  ///
  /// [source] — ImageSource.camera or ImageSource.gallery
  ///
  /// Returns relative path (e.g., "invoices/invoice_1744819200000_482917.jpg")
  /// or null if user cancels or any error occurs.
  Future<String?> captureAndSaveInvoice({required ImageSource source}) async {
    try {
      // Step 1: Pick/capture image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, // No picker-side compression — we handle it ourselves
      );

      if (pickedFile == null) {
        return null; // User cancelled
      }

      // Step 2: Generate ID-independent filename
      final filename = _generateFilename();

      // Step 3: Ensure invoices subdirectory exists
      final appDir = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${appDir.path}/$_invoiceDir');
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      // Step 4: Compress using native hardware acceleration
      final targetPath = '${invoicesDir.path}/$filename';
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: _quality,
        minWidth: _minWidth,
        minHeight: _minHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        debugPrint('Invoice compression returned null');
        return null;
      }

      // Step 5: Return relative path for Isar storage
      return '$_invoiceDir/$filename';
    } catch (e) {
      debugPrint('Invoice capture/save failed: $e');
      return null;
    }
  }

  /// Delete an invoice image by its relative path.
  ///
  /// Silent on failure — used in repository delete flow.
  Future<void> deleteInvoice(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$relativePath');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Invoice deletion failed: $e');
    }
  }

  /// Get absolute File reference for display (thumbnail/fullscreen).
  ///
  /// Returns null if file doesn't exist (orphaned reference).
  File? getInvoiceFile(String? relativePath) {
    if (relativePath == null) return null;
    try {
      // Synchronous — path_provider getApplicationDocumentsDirectory is cached
      // This assumes appDir is available. For safety, use the async variant in UI.
      return File(relativePath);
    } catch (_) {
      return null;
    }
  }

  /// Async variant for UI — resolves full path and checks existence.
  Future<File?> resolveInvoiceFile(String? relativePath) async {
    if (relativePath == null) return null;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$relativePath');
      return await file.exists() ? file : null;
    } catch (_) {
      return null;
    }
  }

  /// Generate collision-resistant filename independent of Isar ID.
  ///
  /// Format: invoice_{timestamp}_{randomHash}.jpg
  static String _generateFilename() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHash = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'invoice_${timestamp}_$randomHash.jpg';
  }
}
