import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.text, required this.isLoading, required this.onTap});
  final String text;
  final bool isLoading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: isLoading? null: onTap,
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child:
                isLoading
                    ? Lottie.asset('assets/lotties/loading_wave_two.json')
                    : Text(
                      text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
          ),
        ),
      ),
    );
  }
}
