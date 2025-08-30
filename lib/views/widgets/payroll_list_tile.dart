import 'package:flutter/material.dart';
import 'package:animation_list/animation_list.dart';

class PayrollListTileWidget extends StatelessWidget {
  final String title;
  final String paymentType;
  final DateTime? joinedDate;
  final Function onTap;

  const PayrollListTileWidget({
    required this.title,
    required this.paymentType,
    required this.joinedDate, 
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      child: AnimationList(
        reBounceDepth: 10,
        duration: 1300,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          InkWell(
            onTap: () => onTap(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 20,),
                          ),
                        ),
                      ),
                      Text('pay: $paymentType', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[500])),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Joined: ${joinedDate?.toLocal().toString().split(' ')[0]}', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[500])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
