import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateOnly(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTimeOnly(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateVN(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
    return formatter.format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay ${formatTimeOnly(date)}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua ${formatTimeOnly(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước ${formatTimeOnly(date)}';
    } else {
      return formatDate(date);
    }
  }

  static String formatOrderDate(DateTime date) {
    return formatRelativeDate(date);
  }
}
