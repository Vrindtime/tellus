import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';

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

Future<String?> saveImageAndGetUrl({
  required XFile file,
  required String bucketId,
}) async {
  try {
    final storage = Get.find<Storage>();
    final result = await storage.createFile(
      bucketId: bucketId,
      fileId: 'unique()',
      file: InputFile.fromPath(path: file.path),
    );
    final fileId = result.$id;
    return '${CId.endPoint}/storage/buckets/$bucketId/files/$fileId/view?project=${CId.project}&mode=admin';
  } catch (e) {
    print('Error uploading file: $e');
    return null;
  }
}

DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime endOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}