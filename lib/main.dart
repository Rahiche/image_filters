import 'package:flutter/material.dart';
import 'package:image_filters/sections/1_basics/basic_filters.dart';

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

// Model for demo items
class DemoItem {
  final String title;
  final Widget content;

  DemoItem({
    required this.title,
    required this.content,
  });
}

// Home screen with grid view
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List<DemoItem> demos = [
    DemoItem(
      title: 'Basic Image Filters',
      content: BasicImageFilters(),
    ),
    DemoItem(
      title: 'Color Demo',
      content: ColorDemo(),
    ),
    DemoItem(
      title: 'Text Demo',
      content: TextDemo(),
    ),
    DemoItem(
      title: 'Button Demo',
      content: ButtonDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demos'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: demos.length,
        itemBuilder: (context, index) {
          return DemoCard(demo: demos[index]);
        },
      ),
    );
  }
}

// Card widget for each demo item
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

// Screen for individual demos
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

// Sample demo content widgets
class CounterDemo extends StatefulWidget {
  const CounterDemo({super.key});

  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Counter Value: $_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _counter++),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

class ColorDemo extends StatelessWidget {
  const ColorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorBox(color: Colors.red),
              ColorBox(color: Colors.green),
              ColorBox(color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class ColorBox extends StatelessWidget {
  final Color color;

  const ColorBox({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class TextDemo extends StatelessWidget {
  const TextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Headline Large',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            'Headline Medium',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Body Large',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Body Medium',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class ButtonDemo extends StatelessWidget {
  const ButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('Elevated Button'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Outlined Button'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Text Button'),
          ),
        ],
      ),
    );
  }
}
