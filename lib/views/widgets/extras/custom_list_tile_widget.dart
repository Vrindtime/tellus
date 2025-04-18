import 'package:flutter/material.dart';
import 'package:animation_list/animation_list.dart';

class UserListTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final Function onTap;

  const UserListTileWidget({
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: AnimationList(
        duration: 1200,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child:
                      avatarUrl != null
                          ? CircleAvatar(
                            child: Image.network(avatarUrl!),
                          )
                          : CircleAvatar(child: Icon(Icons.person)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () => onTap(),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
