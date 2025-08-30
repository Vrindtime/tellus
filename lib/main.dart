import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/core/routes.dart';
import 'package:tellus/core/theme.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize("d89df3c2-1d02-4c36-9755-16abfff76612");
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);
  // This makes notifications show in foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Notification received in foreground: ${event.notification.title}");
    Fluttertoast.showToast(
      msg: event.notification.body ?? "New notification",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
    // This line actually displays the notification
    event.notification.display();
  });

  await GetStorage.init();

  Client client = Client();
  client.setEndpoint(CId.endPoint).setProject(CId.project);

  Account account = Account(client);
  Databases databases = Databases(client);
  Storage storage = Storage(client);

  Get.put(client);
  Get.put(account);
  Get.put(databases);
  Get.put(storage);

  await Get.putAsync(() => AuthService().init());

  WidgetsBinding.instance.addPostFrameCallback((_) {});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      themeMode: ThemeMode.light,
      getPages: getPages,
      initialRoute: '/gate',
    );
  }
}
