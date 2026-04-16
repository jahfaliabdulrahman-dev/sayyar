import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Handles invoice image lifecycle: pick → compress → sandbox save.
///
/// Zero cloud interaction. All paths are relative for Isar storage.
/// Returns null on user cancel or any failure — never crashes the app.
class LocalInvoiceStorageService {
  static const _invoiceDir = 'invoices';

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

      // Step 4: Copy picked file to our sandbox (guaranteed persistence)
      final targetPath = p.join(invoicesDir.path, filename);
      final sourceFile = File(pickedFile.path);
      final targetFile = File(targetPath);
      await sourceFile.copy(targetPath);

      // Verify persistence + integrity
      if (!await targetFile.exists()) {
        debugPrint('[INVOICE SAVE] CRITICAL: Copy failed!');
        return null;
      }

      final sourceSize = await sourceFile.length();
      final savedSize = await targetFile.length();

      // Data integrity check — partial copy detection
      if (savedSize != sourceSize) {
        debugPrint('[INVOICE SAVE] CRITICAL: Partial copy! source=$sourceSize saved=$savedSize');
        await targetFile.delete(); // Clean up corrupt partial file
        return null;
      }

      if (savedSize == 0) {
        debugPrint('[INVOICE SAVE] CRITICAL: Zero-byte file!');
        await targetFile.delete();
        return null;
      }

      debugPrint('[INVOICE SAVE] Verified: $targetPath ($savedSize bytes, integrity OK)');

      // List ALL files in invoices directory for forensic tracking
      final allFiles = await invoicesDir.list().toList();
      debugPrint('[INVOICE SAVE] Directory contents: ${allFiles.map((f) => f.path).toList()}');

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
      final absolutePath = p.join(appDir.path, relativePath);
      final file = File(absolutePath);
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
      final absolutePath = p.join(appDir.path, relativePath);
      final file = File(absolutePath);
      final exists = await file.exists();
      debugPrint('[INVOICE RESOLVE] appDir.path: ${appDir.path}');
      debugPrint('[INVOICE RESOLVE] relativePath: $relativePath');
      debugPrint('[INVOICE RESOLVE] absolutePath: $absolutePath');
      debugPrint('[INVOICE RESOLVE] file exists: $exists');
      if (exists) {
        final stat = await file.stat();
        debugPrint('[INVOICE RESOLVE] file size: ${stat.size} bytes');
      } else {
        // File missing — list directory contents for forensic analysis
        final invoicesDir = Directory(p.join(appDir.path, 'invoices'));
        if (await invoicesDir.exists()) {
          final allFiles = await invoicesDir.list().toList();
          debugPrint('[INVOICE RESOLVE] MISSING! Directory contents: ${allFiles.map((f) => f.path).toList()}');
        } else {
          debugPrint('[INVOICE RESOLVE] MISSING! Invoices directory does not exist!');
        }
      }
      return exists ? file : null;
    } catch (e) {
      debugPrint('[INVOICE RESOLVE] EXCEPTION: $e');
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
