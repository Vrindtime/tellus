import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tellus/core/id.dart';
import 'package:tellus/core/routes.dart';
import 'package:tellus/core/theme.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tellus/services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  Client client = Client();
  client
      .setEndpoint(CId.endPoint)
      .setProject(CId.project);

  Account account = Account(client);
  Databases databases = Databases(client);

  Get.put(client);
  Get.put(account);
  Get.put(databases);

  
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
