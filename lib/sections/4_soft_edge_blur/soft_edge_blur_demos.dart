import 'package:flutter/material.dart';
import 'package:image_filters/main.dart';
import 'package:image_filters/sections/4_soft_edge_blur/airbnb.dart';
import 'package:image_filters/sections/4_soft_edge_blur/map.dart';
import 'package:image_filters/sections/4_soft_edge_blur/music_playlist.dart';
import 'package:image_filters/sections/4_soft_edge_blur/wallpapers.dart';

class SoftEdgeBlurDemos extends StatefulWidget {
  const SoftEdgeBlurDemos({super.key});

  @override
  State<SoftEdgeBlurDemos> createState() => _SoftEdgeBlurDemosState();
}

class _SoftEdgeBlurDemosState extends State<SoftEdgeBlurDemos> {
  @override
  Widget build(BuildContext context) {
    return const AppChooserHome();
  }
}

class AppChooserHome extends StatefulWidget {
  const AppChooserHome({super.key});

  @override
  State<AppChooserHome> createState() => _AppChooserHomeState();
}

class _AppChooserHomeState extends State<AppChooserHome> {
  final List<DemoItem> demos = [
    DemoItem(
      title: 'Map',
      content: const MapApp(),
    ),
    DemoItem(
      title: 'Card',
      content: const AirbnbCard(),
    ),
    DemoItem(
      title: 'Music Playlist',
      content: const MusicPlayerHome(),
    ),
    DemoItem(
      title: 'Wallpapers',
      content: const Wallpapers(),
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
