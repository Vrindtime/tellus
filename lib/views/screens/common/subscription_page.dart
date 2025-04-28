import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Subscription'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation Placeholder
                  Container(
                    height: 200,
                    width: 200,
                    child: Lottie.asset(
                      'assets/lotties/subscription.json', // Replace with your animation.json path
                      fit: BoxFit.contain,
                      onLoaded: (composition) {
                        // Optional: Handle animation loaded
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        size: 100,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Welcome to Our Tellus App!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'This is a demo version of our application. We are working hard to bring you a full-featured experience, including:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Features List
                  _buildFeatureItem('Complete Finacial Report'),
                  _buildFeatureItem('Payroll Management'),
                  _buildFeatureItem('Operator Work Assignment Interfaces'),
                  _buildFeatureItem('Driver Work Assignment Interfaces'),
                  const SizedBox(height: 24),
                  // Launch Date
                  Text(
                    'Full Launch: 21 - May - 2025',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Call to Action
                  // Text(
                  //   'Stay tuned for the official release!',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     color: Colors.blueGrey[600],
                  //     fontStyle: FontStyle.italic,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 32),
                  // // Optional Button (e.g., for future subscription interest)
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Placeholder for future action (e.g., notify me)
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Stay tuned for updates!')),
                  //     );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.blueAccent,
                  //     foregroundColor: Colors.white,
                  //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     elevation: 5,
                  //   ),
                  //   child: const Text(
                  //     'Keep Me Updated',
                  //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            feature,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}