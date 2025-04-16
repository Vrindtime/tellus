import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  final bool _hasNotification = false;
  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: _hasNotification?
        Text('Notification\nPage',style: Theme.of(context).textTheme.headlineLarge,):
        Lottie.asset('assets/lotties/No_Notification.json'),
      ),
    );
  }
}