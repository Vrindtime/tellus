// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:dot_curved_bottom_nav/dot_curved_bottom_nav.dart';

// class BottomNavigationMenuPage extends StatefulWidget {
//   const BottomNavigationMenuPage({super.key, required this.text});
//   final String? text;
//   @override
//   State<BottomNavigationMenuPage> createState() =>
//       _BottomNavigationMenuPageState();
// }

// class _BottomNavigationMenuPageState extends State<BottomNavigationMenuPage>
//     with TickerProviderStateMixin {
//   bool isValid = false;
//   late AnimationController _animationController;
//   int _currentPage = 0;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the AnimationController with a default duration
//     _animationController = AnimationController(vsync: this);

//     // Add a listener to detect when the animation completes
//     _animationController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {
//           isValid = true;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isValid
//         ? Scaffold(
//           body: Center(
//             child: Text('Hello ${widget.text ?? "None"} $_currentPage!'),
//           ),
//           bottomNavigationBar: DotCurvedBottomNav(
//             scrollController: _scrollController,
//             hideOnScroll: true,
//             indicatorColor: Theme.of(context).colorScheme.secondary,
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             animationDuration: const Duration(milliseconds: 300),
//             animationCurve: Curves.ease,
//             // margin: const EdgeInsets.all(0),
//             selectedIndex: _currentPage,
//             indicatorSize: 5,
//             borderRadius: 10,
//             height: 60,
//             onTap: (index) {
//               setState(() => _currentPage = index);
//             },
//             items: [
//               Icon(
//                 Icons.home,
//                 color:
//                     _currentPage == 0
//                         ? Theme.of(context).colorScheme.onSurface
//                         : Colors.white?.withOpacity(0.4),
//               ),
//               Icon(
//                 Icons.file_copy,
//                 color:
//                     _currentPage == 1
//                         ? Theme.of(context).colorScheme.onSurface
//                         : Colors.white?.withOpacity(0.4),
//               ),
//               Icon(
//                 Icons.map,
//                 color:
//                     _currentPage == 2
//                         ? Theme.of(context).colorScheme.onSurface
//                         : Colors.white?.withOpacity(0.4),
//               ),
//               Icon(
//                 Icons.settings,
//                 color:
//                     _currentPage == 3
//                         ? Theme.of(context).colorScheme.onSurface
//                         : Colors.white?.withOpacity(0.4),
//               ),
//             ],
//           ),
//         )
//         : Scaffold(
//           body: Center(
//             child: Lottie.asset(
//               'assets/lotties/lock.json',
//               width: MediaQuery.of(context).size.width * 0.8,
//               controller: _animationController,
//               onLoaded: (composition) {
//                 // Set the animation duration to 80% of the original for 1.25x speed
//                 _animationController.duration = composition.duration * 0.5;
//                 // Play the animation
//                 _animationController.forward();
//               },
//             ),
//           ),
//         );
//   }
// }
