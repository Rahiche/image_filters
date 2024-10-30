import 'package:flutter/material.dart';
import 'package:image_filters/live_coding/onboarding_with_blur.dart';
import 'package:image_filters/sections/1_basics/basic_filters.dart';
import 'package:image_filters/sections/2_combine/compose_filters.dart';
import 'package:image_filters/sections/3_blur/blur.dart';
import 'package:image_filters/sections/4_soft_edge_blur/soft_edge_blur_demos.dart';
import 'package:image_filters/sections/5_fragment_shaders/custom_image_filter_with_shaders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Grid',
      theme: ThemeData.dark(useMaterial3: true),
      home: HomeScreen(),
    );
  }
}

class DemoItem {
  final String title;
  final Widget content;

  DemoItem({
    required this.title,
    required this.content,
  });
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<DemoItem> demos = [
    DemoItem(
      title: '1. Basic Image Filters',
      content: const BasicImageFilters(),
    ),
    DemoItem(
      title: '2. Compose Image Filters',
      content: const ComposeImageFilters(),
    ),
    DemoItem(
      title: '3. Blur',
      content: const BlurDeepDive(),
    ),
    DemoItem(
      title: '4. Soft Edge Blur',
      content: const SoftEdgeBlurDemos(),
    ),
    DemoItem(
      title: '5. Custom Image Filters',
      content: const CustomImageFilterWithShaders(),
    ),
    DemoItem(
      title: '6. Onboarding with blur',
      content: const OnboardingWithBlur(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demos'),
      ),
      body: Center(
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
      ),
    );
  }
}

class DemoCard extends StatelessWidget {
  final DemoItem demo;

  const DemoCard({super.key, required this.demo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DemoScreen(demo: demo),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              demo.title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class DemoScreen extends StatelessWidget {
  final DemoItem demo;

  const DemoScreen({super.key, required this.demo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(demo.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: demo.content,
    );
  }
}
