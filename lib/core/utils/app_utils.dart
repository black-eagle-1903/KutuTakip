import 'package:intl/intl.dart';

/// Utility functions for date formatting and text manipulation
class AppUtils {
  // Prevent instantiation
  AppUtils._();

  // ============ DATE FORMATTING ============

  /// Format DateTime to Turkish date string (e.g., "17 Haziran 2026")
  static String formatDate(DateTime date) {
    return DateFormat('d MMMM y', 'tr_TR').format(date);
  }

  /// Format DateTime to Turkish date and time string (e.g., "17 Haziran 2026, 14:30")
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMMM y, HH:mm', 'tr_TR').format(date);
  }

  /// Format DateTime to time only (e.g., "14:30")
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'tr_TR').format(date);
  }

  /// Format DateTime to short date (e.g., "17.06.2026")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd.MM.y', 'tr_TR').format(date);
  }

  /// Get relative time string (e.g., "2 saat önce", "bugün", "yarın")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDateShort(date);
    } else if (difference.inDays > 1) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  // ============ TEXT MANIPULATION ============

  /// Convert text to Turkish lowercase (handles İ → i, I → ı)
  static String turkishLowercase(String text) {
    return text
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .toLowerCase();
  }

  /// Case-insensitive substring check (Turkish-aware)
  static bool containsIgnoreCaseTurkish(String text, String substring) {
    return turkishLowercase(text).contains(turkishLowercase(substring));
  }

  /// Truncate text with ellipsis
  static String truncate(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Format quantity with Turkish suffix
  static String formatQuantity(int quantity) {
    return quantity == 1 ? '$quantity adet' : '$quantity adet';
  }

  /// Capitalize first letter (Turkish-aware)
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    final firstChar = text[0];
    final capitalized = firstChar == 'i' ? 'İ' : firstChar.toUpperCase();
    return capitalized + text.substring(1);
  }

  // ============ VALIDATION ============

  /// Validate box title (not empty, reasonable length)
  static String? validateBoxTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık boş olamaz';
    }
    if (value.length > 100) {
      return 'Başlık çok uzun (maksimum 100 karakter)';
    }
    return null;
  }

  /// Validate item name (not empty, reasonable length)
  static String? validateItemName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Eşya adı boş olamaz';
    }
    if (value.length > 100) {
      return 'Eşya adı çok uzun (maksimum 100 karakter)';
    }
    return null;
  }

  /// Validate quantity (positive integer)
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Miktar boş olamaz';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < 1) {
      return 'Miktar 1 veya daha büyük olmalı';
    }
    if (parsed > 9999) {
      return 'Miktar çok fazla (maksimum 9999)';
    }
    return null;
  }

  // ============ FILE & PATH HELPERS ============

  /// Extract filename from file path
  static String filenameFromPath(String path) {
    return path.split('/').last.split('\\').last;
  }

  /// Extract directory from file path
  static String dirFromPath(String path) {
    final lastSlash = path.lastIndexOf('/');
    if (lastSlash == -1) {
      return '';
    }
    return path.substring(0, lastSlash);
  }

  /// Convert bytes to human-readable format
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
