import 'package:flutter/material.dart';
import 'package:image_filters/external/utils/mobile_frame.dart';
import 'package:image_filters/live_coding/onboarding.dart';

class OnboardingWithBlur extends StatefulWidget {
  const OnboardingWithBlur({super.key});

  @override
  State<OnboardingWithBlur> createState() => _OnboardingWithBlurState();
}

class _OnboardingWithBlurState extends State<OnboardingWithBlur> {
  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Builder(
        builder: (context) {
          return const InteractiveImagePage();
        },
      ),
    );
  }
}
