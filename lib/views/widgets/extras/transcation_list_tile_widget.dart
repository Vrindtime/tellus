import 'package:flutter/material.dart';
import 'package:animation_list/animation_list.dart';

class TransactionListTileWidget extends StatelessWidget {
  final String title;
  final String status;
  final String total;
  final String startdate;
  final String? enddate;
  final Function onTap;
  final Function? share;
  final Function? pay;

  const TransactionListTileWidget({
    required this.title,
    required this.status,
    required this.total,
    required this.startdate,
    this.enddate,
    required this.onTap,
    this.share,
    this.pay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: MediaQuery.of(context).size.height * 0.13,
      child: AnimationList(
        duration: 1200,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                          ).textTheme.titleMedium?.copyWith(fontSize: 20),
                        ),
                      ),
                    ),
                    Text(startdate, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[500])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(status, style: Theme.of(context).textTheme.bodyMedium),
                    (enddate!=null && startdate != enddate)?Text(enddate!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[500])):SizedBox.shrink(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Total: ', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
                        Text(total, style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (pay!=null)?IconButton(
                          icon: Icon(Icons.request_page),
                          onPressed: () => pay!(),
                          color: Theme.of(context).colorScheme.secondary,
                          iconSize: 20,
                        ):SizedBox.shrink(),
                        (share!=null)?IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () => share!(),
                          color: Theme.of(context).colorScheme.secondary,
                          iconSize: 20,
                        ):SizedBox.shrink(),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: () => onTap(),
                          color: Theme.of(context).colorScheme.secondary,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
