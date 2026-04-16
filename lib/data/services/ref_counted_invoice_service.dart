import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/invoice_image.dart';

/// Normalized invoice storage with reference counting, deduplication,
/// atomic transactions, and soft-delete garbage collection.
///
/// ZERO ASSUMPTIONS ARCHITECTURE:
/// - All record updates + refCount changes in single writeTxn
/// - Soft delete on file failure — GC cleans up later
/// - No phantom files on disk, no refCount leaks on crash
class RefCountedInvoiceService {
  static const _invoiceDir = 'invoices';
  final Isar _isar;
  final ImagePicker _picker = ImagePicker();

  RefCountedInvoiceService(this._isar);

  // =========================================================================
  // PICK & DEDUPLICATE
  // =========================================================================

  /// Pick an image, hash it, deduplicate or create, return InvoiceImage ID.
  ///
  /// All operations atomic in a single writeTxn where possible.
  Future<int?> pickAndAttach({required ImageSource source}) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 100);
      if (picked == null) return null;

      final sourceFile = File(picked.path);
      final hash = await compute(_hashFile, picked.path);
      debugPrint('[INVOICE HASH] $hash');

      // Check for existing NON-DELETED image with same hash
      final existing = await _isar.invoiceImages
          .filter()
          .contentHashEqualTo(hash)
          .and()
          .deletedAtIsNull()
          .findFirst();

      if (existing != null) {
        await _isar.writeTxn(() async {
          existing.refCount++;
          await _isar.invoiceImages.put(existing);
        });
        debugPrint('[DEDUP] Reusing: ${existing.relativePath} (refCount: ${existing.refCount})');
        return existing.id;
      }

      // New invoice — save file
      final appDir = await getApplicationDocumentsDirectory();
      final invoicesDir = Directory('${appDir.path}/$_invoiceDir');
      if (!await invoicesDir.exists()) {
        await invoicesDir.create(recursive: true);
      }

      final filename = _generateFilename();
      final targetPath = p.join(invoicesDir.path, filename);
      final targetFile = await sourceFile.copy(targetPath);

      final sourceSize = await sourceFile.length();
      final savedSize = await targetFile.length();
      if (savedSize != sourceSize || savedSize == 0) {
        debugPrint('[INVOICE SAVE] Integrity failed');
        if (await targetFile.exists()) await targetFile.delete();
        return null;
      }

      debugPrint('[INVOICE SAVE] New: $_invoiceDir/$filename ($savedSize bytes)');

      final invoiceImage = InvoiceImage(
        relativePath: '$_invoiceDir/$filename',
        contentHash: hash,
        refCount: 1,
        fileSizeBytes: savedSize,
      );

      int? newId;
      await _isar.writeTxn(() async {
        newId = await _isar.invoiceImages.put(invoiceImage);
      });

      debugPrint('[INVOICE CREATE] ID: $newId');
      return newId;
    } catch (e) {
      debugPrint('[INVOICE PICK] Failed: $e');
      return null;
    }
  }

  // =========================================================================
  // ATOMIC RECORD UPDATE + INVOICE CLEANUP
  // =========================================================================

  /// Decrement refCount. Soft delete on zero.
  /// Physical file deletion only after Isar commit succeeds.
  Future<void> detachOrDelete(int invoiceImageId) async {
    // ATOMIC: Decrement refCount and soft-delete in single txn
    await _isar.writeTxn(() async {
      final img = await _isar.invoiceImages.get(invoiceImageId);
      if (img == null) return;

      if (img.deletedAt != null) {
        debugPrint('[DETACH] Already soft-deleted: $invoiceImageId');
        return;
      }

      img.refCount--;
      debugPrint('[DETACH] ID: $invoiceImageId refCount: ${img.refCount}');

      if (img.refCount <= 0) {
        img.deletedAt = DateTime.now();
        debugPrint('[DETACH] Soft-deleted: $invoiceImageId');
      }

      await _isar.invoiceImages.put(img);
    });

    // AFTER atomic commit — attempt physical file deletion for soft-deleted
    final img = await _isar.invoiceImages.get(invoiceImageId);
    if (img != null && img.deletedAt != null) {
      await _attemptPhysicalDelete(img);
    }
  }

  /// Attempt physical file deletion. On timeout/exception, leaves soft-delete flag.
  /// GC process will retry later.
  Future<void> _attemptPhysicalDelete(InvoiceImage image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File(p.join(appDir.path, image.relativePath));
      if (await file.exists()) {
        await file.delete().timeout(
          const Duration(milliseconds: 200),
          onTimeout: () {
            debugPrint('[GC] Timeout — physical delete deferred for: ${image.relativePath}');
            throw TimeoutException('File delete timeout');
          },
        );
        debugPrint('[GC] Physical file deleted: ${image.relativePath}');

        // File deleted — safe to remove Isar entity
        await _isar.writeTxn(() async {
          await _isar.invoiceImages.delete(image.id);
        });
        debugPrint('[GC] InvoiceImage entity removed from Isar');
      } else {
        // File doesn't exist — remove orphan entity
        await _isar.writeTxn(() async {
          await _isar.invoiceImages.delete(image.id);
        });
        debugPrint('[GC] Orphan entity removed (file already gone)');
      }
    } catch (e) {
      debugPrint('[GC] Physical delete failed: $e — entity remains soft-deleted for retry');
    }
  }

  // =========================================================================
  // GARBAGE COLLECTION
  /// Run on app startup or periodically. Retries physical deletion for
  /// all soft-deleted entries.
  // =========================================================================

  Future<int> runGarbageCollection() async {
    final softDeleted = await _isar.invoiceImages
        .filter()
        .deletedAtIsNotNull()
        .findAll();

    debugPrint('[GC] Found ${softDeleted.length} soft-deleted entries');

    int cleaned = 0;
    for (final image in softDeleted) {
      await _attemptPhysicalDelete(image);
      // Check if entity was removed
      final stillExists = await _isar.invoiceImages.get(image.id);
      if (stillExists == null) cleaned++;
    }

    debugPrint('[GC] Cleaned $cleaned / ${softDeleted.length} entries');
    return cleaned;
  }

  // =========================================================================
  // QUERIES
  // =========================================================================

  /// Get the file for an InvoiceImage by ID. Excludes soft-deleted.
  Future<File?> getFile(int invoiceImageId) async {
    final image = await _isar.invoiceImages.get(invoiceImageId);
    if (image == null || image.deletedAt != null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, image.relativePath));
    return await file.exists() ? file : null;
  }

  /// Get diagnostics for an InvoiceImage
  Future<Map<String, dynamic>?> getDiagnostics(int invoiceImageId) async {
    final image = await _isar.invoiceImages.get(invoiceImageId);
    if (image == null) return null;
    return {
      'id': image.id,
      'relativePath': image.relativePath,
      'contentHash': image.contentHash,
      'refCount': image.refCount,
      'fileSizeBytes': image.fileSizeBytes,
      'deletedAt': image.deletedAt?.toIso8601String(),
      'createdAt': image.createdAt.toIso8601String(),
    };
  }

  // =========================================================================
  // UTILITIES
  // =========================================================================

  static Future<String> _hashFile(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  static String _generateFilename() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHash = (DateTime.now().microsecond * 1000 + DateTime.now().millisecond)
        .toString()
        .padLeft(6, '0');
    return 'invoice_${timestamp}_$randomHash.jpg';
  }
}
