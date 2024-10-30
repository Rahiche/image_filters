import 'package:flutter/material.dart';
import 'package:image_filters/main.dart';
import 'package:image_filters/sections/5_fragment_shaders/ios_name_drop_demo.dart';
import 'package:image_filters/sections/5_fragment_shaders/rgb_glitch_demo.dart';
import 'package:image_filters/sections/5_fragment_shaders/ripple_effect_demo.dart';
import 'package:image_filters/sections/5_fragment_shaders/riveo_page_curl_demo.dart';

class CustomImageFilterWithShaders extends StatefulWidget {
  const CustomImageFilterWithShaders({super.key});

  @override
  State<CustomImageFilterWithShaders> createState() =>
      _CustomImageFilterWithShadersState();
}

class _CustomImageFilterWithShadersState
    extends State<CustomImageFilterWithShaders> {
  final List<DemoItem> demos = [
    DemoItem(
      title: 'Ripple Effect',
      content: const RippleEffectDemo(),
    ),
    DemoItem(
      title: 'iOS Name Drop',
      content: const IosNameDropDemo(),
    ),
    DemoItem(
      title: 'RGB Glitch',
      content: const RgbGlitchDemo(),
    ),
    DemoItem(
      title: 'Riveo Page Curl',
      content: const RiveoPageCurlDemo(),
    ),
    DemoItem(
      title: 'TODO: Noise',
      content: const RiveoPageCurlDemo(),
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
