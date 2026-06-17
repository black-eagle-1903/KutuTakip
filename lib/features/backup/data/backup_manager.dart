import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart' as archive_pkg;
import 'dart:convert';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/database/app_database.dart';

/// Service for managing backup and restore operations
class BackupManager {
  final AppDatabase db;

  BackupManager(this.db);

  /// Create a backup ZIP file containing metadata and photos
  /// Returns the path to the created ZIP file
  Future<String> createBackup() async {
    try {
      // Get app document directory
      final appDocDir = await getApplicationDocumentsDirectory();

      // Export all data from database
      final allData = await db.exportAllData();

      // Create metadata JSON
      final metadataJson = jsonEncode(allData);

      // Create archive
      final archive = archive_pkg.Archive();

      // Add metadata.json to archive
      final metadataBytes = utf8.encode(metadataJson);
      archive.addFile(
        archive_pkg.ArchiveFile(
          AppConstants.metadataFileName,
          metadataBytes.length,
          metadataBytes,
        ),
      );

      // Add all photos to archive
      final photosDir = Directory('${appDocDir.path}/${AppConstants.photosDirectoryName}');
      if (await photosDir.exists()) {
        await _addPhotosToArchive(archive, photosDir);
      }

      // Encode archive to bytes
      final encoder = archive_pkg.ZipEncoder();
      final zipBytes = encoder.encode(archive);

      // Save ZIP to documents directory
      final backupDir = Directory('${appDocDir.path}/${AppConstants.backupDirectoryName}');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipPath = '${backupDir.path}/kututakip_backup_$timestamp.zip';
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes);

      return zipPath;
    } catch (e) {
      throw Exception('Yedekleme başarısız: $e');
    }
  }

  /// Add all photos from directory to archive
  Future<void> _addPhotosToArchive(
    archive_pkg.Archive archive,
    Directory photosDir,
  ) async {
    final photoFiles = photosDir.listSync();
    for (final file in photoFiles) {
      if (file is File) {
        final fileName = file.path.split(Platform.pathSeparator).last;
        final fileBytes = await file.readAsBytes();
        archive.addFile(
          archive_pkg.ArchiveFile(
            '${AppConstants.photosDirNameInZip}/$fileName',
            fileBytes.length,
            fileBytes,
          ),
        );
      }
    }
  }

  /// Restore from a backup ZIP file
  /// Clears existing data and recreates from ZIP
  Future<void> restoreBackup(String zipFilePath) async {
    try {
      final zipFile = File(zipFilePath);
      if (!await zipFile.exists()) {
        throw Exception('Yedek dosyası bulunamadı');
      }

      // Read ZIP bytes
      final zipBytes = await zipFile.readAsBytes();

      // Decode ZIP archive
      final archive = archive_pkg.ZipDecoder().decodeBytes(zipBytes);

      // Get app document directory
      final appDocDir = await getApplicationDocumentsDirectory();

      // Extract metadata.json and parse
      Map<String, dynamic>? metadata;
      for (final file in archive) {
        if (file.name == AppConstants.metadataFileName) {
          final metadataJson = utf8.decode(file.content as List<int>);
          metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
          break;
        }
      }

      if (metadata == null) {
        throw Exception('Yedek dosyasında metadata bulunamadı');
      }

      // Clear photos directory
      final photosDir = Directory('${appDocDir.path}/${AppConstants.photosDirectoryName}');
      if (await photosDir.exists()) {
        await photosDir.delete(recursive: true);
      }
      await photosDir.create(recursive: true);

      // Extract photos
      for (final file in archive) {
        if (file.name.startsWith('${AppConstants.photosDirNameInZip}/')) {
          final fileName = file.name.split('/').last;
          final photoPath = '${photosDir.path}/$fileName';
          final photoFile = File(photoPath);
          await photoFile.writeAsBytes(file.content as List<int>);
        }
      }

      // Import metadata to database
      await db.importData(metadata);
    } catch (e) {
      throw Exception('Geri yükleme başarısız: $e');
    }
  }

  /// Get human-readable file size
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
