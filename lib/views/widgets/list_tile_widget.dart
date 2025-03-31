import 'package:animation_list/animation_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tellus/services/auth/auth_service.dart';
import 'package:tellus/views/screens/auth/organization.dart';

class ListTileWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ListTileWidget({required this.items, super.key});

  Widget _buildTile(
    String title,
    Widget page,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () async {
        if (title == "Logout") {
          final authService = Get.find<AuthService>();
          await authService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: OrganizationPage(), // Replace with your organization page widget
            ),
            (route) => false,
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: page,
            ),
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.075,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: title == "Logout" ? Colors.red : null,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimationList(
      duration: 1200,
      animationDirection: AnimationDirection.horizontal,
      children: items.map((item) {
        return _buildTile(
          item['title'],
          item['page'],
          context,
        );
      }).toList(),
    );
  }
}
