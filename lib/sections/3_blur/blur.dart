import 'package:flutter/material.dart';
import 'package:image_filters/main.dart';
import 'package:image_filters/sections/3_blur/backdrop_key.dart';
import 'package:image_filters/sections/3_blur/blur_with_package_image.dart';
import 'package:image_filters/sections/3_blur/flutter_blur_performance.dart';
import 'package:image_filters/sections/3_blur/what_is_a_blur.dart';

// demos:
// 1. blur usage examples
// 1. how blur works
// 2. blur with cpu
// 3. blur in flutter, how is it so fast?
// 4. backdrop group key, different tile modes, backdrop layer issue
class BlurDeepDive extends StatefulWidget {
  const BlurDeepDive({super.key});

  @override
  State<BlurDeepDive> createState() => _BlurDeepDiveState();
}

class _BlurDeepDiveState extends State<BlurDeepDive> {
  final List<DemoItem> demos = [
    DemoItem(
      title: 'What is a blur?',
      content: const WhatIsABlur(),
    ),
    DemoItem(
      title: 'Blur with package:image',
      content: const BlurWithPackageImage(),
    ),
    DemoItem(
      title: 'Why so fast?',
      content: const FlutterBlurPerformance(),
    ),
    DemoItem(
      title: 'Backdrop key',
      content: const BackdropFilterDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: demos.length,
          itemBuilder: (context, index) {
            return DemoCard(demo: demos[index]);
          },
        ),
      ),
    );
  }
}
