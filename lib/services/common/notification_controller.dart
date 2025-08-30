import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/models/notification_model.dart';
import 'package:tellus/services/auth/auth_service.dart';

class NotificationController extends GetxController {
  final Databases databases = Get.find<Databases>();
  final AuthService authService = Get.find<AuthService>();

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  Future<void> fetchNotifications() async {
    final orgId = authService.orgId.value;
    if (orgId.isEmpty) return;
    try {
      isLoading.value = true;
      final response = await databases.listDocuments(
        databaseId: CId.databaseId,
        collectionId: CId.notificationCollectionId,
        queries: [Query.equal('organizationId', orgId)],
      );
      notifications.assignAll(
        response.documents.map((doc) => NotificationModel.fromJson(doc.data)).toList(),
      );
    } catch (e) {
      // Optionally handle error
    } finally {
      isLoading.value = false;
    }
  }

  void addNotification(NotificationModel notification) {
    notifications.insert(0, notification);
  }

  void clearNotifications() {
    notifications.clear();
  }
}
