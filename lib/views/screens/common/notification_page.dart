import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tellus/services/common/notification_controller.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController = Get.put(NotificationController());
    notificationController.fetchNotifications();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Obx(() {
        final notifications = notificationController.notifications;
        if (notificationController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notifications.isEmpty) {
          return Center(
            child: Lottie.asset('assets/lotties/No_Notification.json'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final n = notifications[i];
            return ListTile(
              leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
              title: Text(n.title, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(n.message),
              trailing: Text(DateFormat('yyyy-MM-dd').format(n.date), style: Theme.of(context).textTheme.bodySmall),
            );
          },
        );
      }),
    );
  }
}