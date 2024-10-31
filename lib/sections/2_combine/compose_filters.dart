import 'package:flutter/material.dart';
import 'package:image_filters/main.dart';
import 'package:image_filters/sections/2_combine/lens_like_demo.dart';
import 'package:image_filters/sections/2_combine/motion_demo.dart';
import 'package:image_filters/sections/2_combine/saturated_demo.dart';
import 'package:image_filters/sections/2_combine/shader_mask_demo.dart';

class ComposeImageFilters extends StatefulWidget {
  const ComposeImageFilters({super.key});

  @override
  State<ComposeImageFilters> createState() => _ComposeImageFiltersState();
}

class _ComposeImageFiltersState extends State<ComposeImageFilters> {
  final List<DemoItem> demos = [
    DemoItem(
      title: 'Lens Like',
      content: const LensLikeDemo(),
    ),
    DemoItem(
      title: 'Motion',
      content: const MotionDemo(),
    ),
    DemoItem(
      title: 'Saturated',
      content: const SaturatedDemo(),
    ),
    DemoItem(
      title: 'Shadermask',
      content: const ShaderMaskDemo(),
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
