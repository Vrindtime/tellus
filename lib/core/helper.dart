import 'package:intl/intl.dart';

DateTime customParseDate(String dateStr) {
  try {
    // First, try parsing as ISO 8601 (e.g., "2025-04-01T17:18:02.377Z")
    return DateTime.parse(dateStr);
  } catch (e) {
    try {
      // Fallback to custom format "dd-MM-yyyy HH:mm:ss.SSS"
      final dateFormat = DateFormat('dd-MM-yyyy HH:mm:ss.SSS');
      return dateFormat.parse(dateStr);
    } catch (e) {
      print('Failed to parse date: $dateStr, error: $e');
      return DateTime.now(); // Fallback to current date if parsing fails
    }
  }
}