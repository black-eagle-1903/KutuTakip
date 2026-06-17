import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/features/backup/data/backup_manager.dart';
import 'package:kututakip/providers/app_providers.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final backupManager = BackupManager(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.backupTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Yedekleme Hakkında',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tüm kutular, eşyalar ve fotoğrafları tek bir dosyada saklayın. '
                      'Yedekleme dosyasını paylaşabilir veya daha sonra geri yükleyebilirsiniz.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create & Share Backup Button
            _buildMainButton(
              onPressed: () => _handleCreateBackup(context, backupManager),
              icon: Icons.backup,
              title: AppConstants.backupAction,
              subtitle: 'Yedek Oluştur ve Paylaş',
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Restore Backup Button
            _buildMainButton(
              onPressed: () => _handleRestoreBackup(context, ref, backupManager),
              icon: Icons.restore,
              title: 'Geri Yükle',
              subtitle: 'Yedeği Geri Yükle',
              color: Colors.orange,
            ),
            const SizedBox(height: 32),

            // Warning Card
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uyarı',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Geri yükleme işlemi mevcut tüm verileri değiştirecektir. '
                            'Işlemi gerçekleştirmeden önce emin olun.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateBackup(
    BuildContext context,
    BackupManager backupManager,
  ) async {
    try {
      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create backup
      final backupPath = await backupManager.createBackup();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Share backup file
      await Share.shareXFiles(
        [XFile(backupPath)],
        text: 'KutuTakip Yedekleme Dosyası',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRestoreBackup(
    BuildContext context,
    WidgetRef ref,
    BackupManager backupManager,
  ) async {
    try {
      // Show confirmation dialog first
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Yedeği Geri Yükle'),
          content: const Text(
            'Bu işlem mevcut tüm verileri değiştirecektir. '
            'Devam etmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppConstants.cancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Geri Yükle'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Pick ZIP file
      if (!context.mounted) return;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: 'Yedek Dosyasını Seç',
      );

      if (result == null || result.files.isEmpty) return;

      final zipPath = result.files.first.path;
      if (zipPath == null) return;

      // Show loading dialog
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Restore backup
      await backupManager.restoreBackup(zipPath);

      // Refresh all providers
      ref.refresh(allBoxesProvider);
      ref.refresh(boxStatisticsProvider);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show success message and pop back to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.restoreSuccessMessage),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      if (context.mounted) {
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
