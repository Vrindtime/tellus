import 'package:flutter/material.dart';

class CommonPage extends StatelessWidget {
  const CommonPage({super.key, required this.pagename});

  final String pagename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          pagename,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
