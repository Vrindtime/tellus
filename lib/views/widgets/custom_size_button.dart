import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomSubmitButton extends StatelessWidget {
  const CustomSubmitButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onTap,
    this.height = 50.0, 
    this.width = double.infinity, 
    this.backgroundColor,
    this.padding = 10.0,
  });
  final String text;
  final bool isLoading;
  final VoidCallback onTap;
  final double height; 
  final double width; 
  final Color? backgroundColor; 
  final double? padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding!),
      child: GestureDetector(
        onTap: isLoading? null: onTap,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).colorScheme.primary,
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
