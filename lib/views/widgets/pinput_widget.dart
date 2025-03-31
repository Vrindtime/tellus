import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

// ignore: must_be_immutable
class PinputInput extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final pinController;
  bool isComplete;
  PinputInput({super.key, this.pinController, required this.isComplete});

  @override
  State<PinputInput> createState() => _PinputInputState();
}

class _PinputInputState extends State<PinputInput> {
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color:Theme.of(context).colorScheme.secondary ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
    );
    return Pinput(
      controller: widget.pinController,
      length: 6,
      defaultPinTheme: defaultPinTheme,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      onCompleted: (pin) {
        debugPrint('onCompleted: $pin');
        setState(() {
          widget.isComplete = true;
        });
      }
    );
  }
}