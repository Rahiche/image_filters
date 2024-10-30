import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:image_filters/external/utils/mobile_frame.dart';

class RgbGlitchDemo extends StatefulWidget {
  const RgbGlitchDemo({super.key});

  @override
  State<RgbGlitchDemo> createState() => _RgbGlitchDemoState();
}

class _RgbGlitchDemoState extends State<RgbGlitchDemo> {
  @override
  Widget build(BuildContext context) {
    return const MobileFrame(child: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderBuilder(
          (context, shader, _) {
            return AnimatedSampler(
              (image, size, canvas) {
                final animation = TweenSequence<double>([
                  TweenSequenceItem(
                    tween: Tween<double>(begin: 0.0, end: 1.0)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                    weight: 50.0,
                  ),
                  TweenSequenceItem(
                    tween: Tween<double>(begin: 1.0, end: 0.0)
                        .chain(CurveTween(curve: Curves.easeInOut)),
                    weight: 50.0,
                  ),
                ]).animate(_controller);
                shader
                  ..setFloat(0, size.width) // iResolution
                  ..setFloat(1, size.height) // iResolution
                  ..setFloat(2, animation.value) // iTime
                  ..setImageSampler(0, image); // i

                canvas.drawRect(
                  Rect.fromLTWH(
                    0,
                    0,
                    size.width,
                    size.height,
                  ),
                  Paint()..shader = shader,
                );
              },
              child: _buildContent(),
            );
          },
          assetKey: "shaders/rgb_glitch.frag",
        );
      },
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What do you want to watch?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: MoviePoster(
                        imageUrl: 'https://i.imgur.com/JQXlNVg.png',
                        label: 'Wish',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _controller.forward(),
                        child: const MoviePoster(
                          imageUrl: 'https://i.imgur.com/N8hRNzt.png',
                          label: 'Spider-Man',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const TabBarSection(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark), label: 'Watch list'),
            ],
          ),
        ),
        if (_controller.value >= 0.5)
          MovieDetails(
            imageUrl: 'https://i.imgur.com/N8hRNzt.png',
            onPressBack: () => _controller.animateBack(0),
          )
      ],
    );
  }
}

class MoviePoster extends StatelessWidget {
  final String imageUrl;
  final String label;

  const MoviePoster({super.key, required this.imageUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class TabBarSection extends StatelessWidget {
  const TabBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Now playing'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Top rated'),
                Tab(text: 'Popular'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MovieList(),
                  MovieList(),
                  MovieList(),
                  MovieList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieList extends StatelessWidget {
  MovieList({super.key});

  final List<String> movieImages = [
    'https://i.imgur.com/3XRfbNY.png',
    'https://i.imgur.com/FHi2oBh.png',
    'https://i.imgur.com/Jx39i0M.png',
    'https://i.imgur.com/ZZOLdOv.png',
    'https://i.imgur.com/JQXlNVg.png',
    'https://i.imgur.com/N8hRNzt.png',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: movieImages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(movieImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MovieDetails extends StatefulWidget {
  const MovieDetails(
      {super.key, required this.imageUrl, required this.onPressBack});
  final String imageUrl;
  final VoidCallback onPressBack;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => widget.onPressBack(),
          ),
          title: const Text('Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 20),
                          SizedBox(width: 4),
                          Text(
                            '9.5',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spider-Man: Across the Spider-Verse',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '2023',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 16),
                        Text(
                          '148 Minutes',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Action',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About Movie',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'In an attempt to curb the Spot, a scientist, from harnessing the power of the multiverse, Miles Morales joins forces with Gwen Stacy.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
