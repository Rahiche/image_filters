import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Image Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const InteractiveImagePage(),
    );
  }
}

class InteractiveImagePage extends StatefulWidget {
  const InteractiveImagePage({super.key});

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _animationController;
  int? _currentAnimationIndex;

  // List of preset animations
  final List<Map<String, dynamic>> _animationPresets = [
    {
      'gradientRadius': 1700.0,
      'focalRadius': 20.0,
      'centerX': 0.4,
      'centerY': 0.0,
    },
    {
      'gradientRadius': 1500.0,
      'focalRadius': 20.0,
      'centerX': 0.5,
      'centerY': 0.0,
    },
    {
      'gradientRadius': 254.0,
      'focalRadius': 108.0,
      'centerX': 0.1,
      'centerY': 0.5,
    },
    {
      'gradientRadius': 247.0,
      'focalRadius': 145.0,
      'centerX': 1.0,
      'centerY': 0.0,
    },
    {
      'gradientRadius': 800.0,
      'focalRadius': 145.0,
      'centerX': 1.0,
      'centerY': 1.0,
    },
    {
      'gradientRadius': 2200.0,
      'focalRadius': 2000.0,
      'centerX': 1.0,
      'centerY': 1.0,
    },
  ];

  //Offset? interactionPosition;
  bool isInteracting = false;
  // Gradient control parameters
  double gradientRadius = 1700.0;
  double focalRadius = 0.0;
  double centerX = .5;
  double centerY = 0.0;
  List<Color> gradientColors = [Colors.transparent, Colors.blue];
  List<double> gradientStops = [0.0, 1.0];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController.addListener(_handleAnimation);
    Future.delayed(const Duration(seconds: 3)).then((value) {
      _animateToNextPreset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnimation() {
    if (_animationController.isAnimating) {
      final currentPreset = _animationPresets[_currentAnimationIndex!];
      final nextPreset = _animationPresets[
          (_currentAnimationIndex! + 1) % _animationPresets.length];

      final progress = _animationController.value;

      setState(() {
        gradientRadius = ui.lerpDouble(
          currentPreset['gradientRadius'] as double,
          nextPreset['gradientRadius'] as double,
          progress,
        )!;

        focalRadius = ui.lerpDouble(
          currentPreset['focalRadius'] as double,
          nextPreset['focalRadius'] as double,
          progress,
        )!;

        centerX = ui.lerpDouble(
          currentPreset['centerX'] as double,
          nextPreset['centerX'] as double,
          progress,
        )!;

        centerY = ui.lerpDouble(
          currentPreset['centerY'] as double,
          nextPreset['centerY'] as double,
          progress,
        )!;
      });
    }
  }

  void _animateToNextPreset() {
    if (_animationController.isAnimating) return;

    _currentAnimationIndex ??= 0;
    _currentAnimationIndex =
        (_currentAnimationIndex! + 1) % _animationPresets.length;
    _animationController.forward(from: 0.0);
  }

  // Update the _buildControlPanel method to add the animation button
  // Widget _buildControlPanel() {
  //   return SingleChildScrollView(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text('Gradient Controls',
  //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  //           const SizedBox(height: 20),
  //           _buildSliderControl(
  //             label: 'Gradient Radius',
  //             value: gradientRadius,
  //             min: 0,
  //             max: 2800,
  //             onChanged: (value) => setState(() => gradientRadius = value),
  //           ),
  //           _buildSliderControl(
  //             label: 'Focal Radius',
  //             value: focalRadius,
  //             min: 0,
  //             max: 2200,
  //             onChanged: (value) => setState(() => focalRadius = value),
  //           ),
  //           _buildSliderControl(
  //             label: 'Center X Offset',
  //             value: centerX,
  //             min: -1,
  //             max: 1,
  //             onChanged: (value) => setState(() => centerX = value),
  //           ),
  //           _buildSliderControl(
  //             label: 'Center Y Offset',
  //             value: centerY,
  //             min: -1,
  //             max: 1,
  //             onChanged: (value) => setState(() => centerY = value),
  //           ),
  //           const SizedBox(height: 20),
  //           const Text('Gradient Colors', style: TextStyle(fontSize: 16)),
  //           const SizedBox(height: 10),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: ElevatedButton(
  //                   onPressed: () async {
  //                     final Color? color =
  //                         await showColorPicker(context, gradientColors[1]);
  //                     if (color != null) {
  //                       setState(() => gradientColors[1] = color);
  //                     }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: gradientColors[1],
  //                     foregroundColor: Colors.white,
  //                   ),
  //                   child: const Text('Change Color'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 20),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: GestureDetector(
  //                   onTap: _animateToNextPreset,
  //                   child: const Padding(
  //                     padding: EdgeInsets.all(8.0),
  //                     child: Text('Animate to Next Preset'),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSliderControl({
  //   required String label,
  //   required double value,
  //   required double min,
  //   required double max,
  //   required ValueChanged<double> onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(label),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: Slider(
  //               value: value,
  //               min: min,
  //               max: max,
  //               onChanged: onChanged,
  //             ),
  //           ),
  //           SizedBox(
  //             width: 50,
  //             child: Text(value.toStringAsFixed(1)),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Future<Color?> showColorPicker(
      BuildContext context, Color initialColor) async {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              selectedColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(selectedColor),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Control Panel
        // SizedBox(
        //   width: 300,
        //   child: _buildControlPanel(),
        // ),

        // Vertical Divider
        // const VerticalDivider(width: 1),

        // Image Display
        Expanded(
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                  // border: Border.all(),
                  ),
              // clipBehavior: Clip.antiAlias,
              child: AnimatedSampler(
                (image, size, canvas) {
                  final devicePixelRatio =
                      MediaQuery.devicePixelRatioOf(context);
                  canvas.scale(1 / devicePixelRatio);

                  canvas.drawImage(image, Offset.zero, Paint());

                  final width = size.width * devicePixelRatio;
                  final height = size.height * devicePixelRatio;
                  final rect = Rect.fromLTWH(0, 0, width, height);
                  canvas.saveLayer(rect, Paint());

                  // Create a paint with blur and grayscale effects
                  final blurredPaint = Paint()
                    ..imageFilter = ui.ImageFilter.blur(
                      sigmaX: 30,
                      sigmaY: 30,
                      tileMode: TileMode.mirror,
                    );
//                       ..colorFilter = const ColorFilter.matrix([
//                         0.2126,
//                         0.7152,
//                         0.0722,
//                         0,
//                         0,
//                         0.2126,
//                         0.7152,
//                         0.0722,
//                         0,
//                         0,
//                         0.2126,
//                         0.7152,
//                         0.0722,
//                         0,
//                         0,
//                         0,
//                         0,
//                         0,
//                         1,
//                         0,
//                       ]);

                  canvas.drawImage(image, Offset.zero, blurredPaint);

//                     if (interactionPosition != null) {
//                       final basePosition = Offset(
//                         interactionPosition!.dx * width,
//                         interactionPosition!.dy * height,
//                       );

                  final adjustedPosition = Offset(
                    (centerX * width),
                    (centerY * height),
                  );

                  final gradient = ui.Gradient.radial(
                    adjustedPosition,
                    gradientRadius,
                    gradientColors,
                    gradientStops,
                    TileMode.clamp,
                    Matrix4.identity().storage,
                    adjustedPosition,
                    focalRadius,
                  );

                  final gradientPaint = Paint()
                    ..shader = gradient
                    ..blendMode = BlendMode.dstIn;

                  canvas.drawRect(rect, gradientPaint);
                  canvas.restore();
//                     }
                },
                child: InteractiveImage(
                  imageUrl: 'https://i.imgur.com/PVxynOu.png',
                  onInteractionUpdate: (double x, double y) {
//                       _updatePosition(Offset(x, y));

                    if (!isInteracting) {
                      setState(() {
                        isInteracting = true;
                      });
                      _animateToNextPreset();
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Interaction started at: ($x, $y)'),
                      //     duration: const Duration(seconds: 2),
                      //   ),
                      // );
                    }
                  },
                  onInteractionEnd: () {
                    setState(() {
                      isInteracting = false;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Simple Color Picker Widget
class ColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var color in [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.teal,
          Colors.pink,
        ])
          GestureDetector(
            onTap: () {
              setState(() => currentColor = color);
              widget.onColorChanged(color);
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: currentColor == color ? Colors.white : Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }
}

// Rest of the classes (InteractiveImage, AnimatedSampler, etc.) remain the same...

class InteractiveImage extends StatelessWidget {
  final String imageUrl;
  final Function(double x, double y) onInteractionUpdate;
  final Function() onInteractionEnd;

  const InteractiveImage({
    super.key,
    required this.imageUrl,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
  });

  void _handleInteraction(Offset globalPosition, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);

    // Calculate relative coordinates (0,0 to 1,1)
    final double relativeX = localPosition.dx / box.size.width;
    final double relativeY = localPosition.dy / box.size.height;

    // Ensure coordinates are within bounds
    final double boundedX = relativeX.clamp(0.0, 1.0);
    final double boundedY = relativeY.clamp(0.0, 1.0);

    onInteractionUpdate(boundedX, boundedY);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _handleInteraction(details.globalPosition, context);
      },
      onPanUpdate: (details) {
        _handleInteraction(details.globalPosition, context);
      },
      onPanEnd: (_) => onInteractionEnd(),
      onTapDown: (details) {
        _handleInteraction(details.globalPosition, context);
      },
      onTapUp: (_) => onInteractionEnd(),
      child: const SocialMediaFeed(),
    );
  }
}

class SocialFeedPost {
  final String username;
  final String imageUrl;
  final String caption;
  final int likes;
  final List<String> comments;

  SocialFeedPost({
    required this.username,
    required this.imageUrl,
    required this.caption,
    this.likes = 0,
    this.comments = const [],
  });
}

class SocialMediaFeed extends StatefulWidget {
  const SocialMediaFeed({super.key});

  @override
  State<SocialMediaFeed> createState() => _SocialMediaFeedState();
}

class _SocialMediaFeedState extends State<SocialMediaFeed> {
  // Sample data - in a real app, this would come from a backend
  final List<SocialFeedPost> _posts = [
    SocialFeedPost(
      username: "john_doe",
      imageUrl: "https://picsum.photos/1200/1200",
      caption: "Beautiful sunset!",
      likes: 42,
      comments: ["Great shot!", "Amazing view!"],
    ),
    SocialFeedPost(
      username: "jane_smith",
      imageUrl: "https://picsum.photos/1200/1201",
      caption: "Weekend vibes ✨",
      likes: 127,
      comments: ["Having fun!", "Wish I was there!"],
    ),
  ];

  bool _isLiked = false;

  void _addNewPost() {
    // Show bottom sheet to add new post
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Post',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () {
                      // Add image picker functionality here
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text('Choose from gallery'),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      // Add camera functionality here
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text('Take a photo'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Add refresh functionality here
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info header
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.imageUrl),
                  ),
                  title: Text(post.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Add more options menu
                    },
                  ),
                ),
                // Post image
                Image.network(
                  post.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {
                        // Add comment functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // Add share functionality
                      },
                    ),
                  ],
                ),
                // Likes count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${post.likes} likes',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Caption
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(post.caption),
                ),
                // Comments
                if (post.comments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: post.comments
                          .map((comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(comment),
                              ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPost,
        child: const Icon(Icons.add),
      ),
    );
  }
}
//
// typedef AnimatedSamplerBuilder = void Function(
//   ui.Image image,
//   Size size,
//   Canvas canvas,
// );
//
// class AnimatedSampler extends StatelessWidget {
//   const AnimatedSampler(this.builder, {required this.child, super.key});
//
//   final AnimatedSamplerBuilder builder;
//   final Widget child;
//
//   @override
//   Widget build(BuildContext context) {
//     return _SamplerBuilder(builder, enabled: true, child: child);
//   }
// }
//
// class _SamplerBuilder extends SingleChildRenderObjectWidget {
//   const _SamplerBuilder(
//     this.builder, {
//     super.child,
//     required this.enabled,
//   });
//
//   final AnimatedSamplerBuilder builder;
//   final bool enabled;
//
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//     return _RenderAnimatedSamplerWidget(
//       devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
//       builder: builder,
//       enabled: enabled,
//     );
//   }
//
//   @override
//   void updateRenderObject(
//       BuildContext context, covariant RenderObject renderObject) {
//     (renderObject as _RenderAnimatedSamplerWidget)
//       ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context)
//       ..builder = builder
//       ..enabled = enabled;
//   }
// }
//
// class _RenderAnimatedSamplerWidget extends RenderProxyBox {
//   _RenderAnimatedSamplerWidget({
//     required double devicePixelRatio,
//     required AnimatedSamplerBuilder builder,
//     required bool enabled,
//   })  : _devicePixelRatio = devicePixelRatio,
//         _builder = builder,
//         _enabled = enabled;
//
//   @override
//   OffsetLayer updateCompositedLayer(
//       {required covariant _SamplerBuilderLayer? oldLayer}) {
//     final _SamplerBuilderLayer layer =
//         oldLayer ?? _SamplerBuilderLayer(builder);
//     layer
//       ..callback = builder
//       ..size = size
//       ..devicePixelRatio = devicePixelRatio;
//     return layer;
//   }
//
//   double get devicePixelRatio => _devicePixelRatio;
//   double _devicePixelRatio;
//   set devicePixelRatio(double value) {
//     if (value == devicePixelRatio) {
//       return;
//     }
//     _devicePixelRatio = value;
//     markNeedsCompositedLayerUpdate();
//   }
//
//   AnimatedSamplerBuilder get builder => _builder;
//   AnimatedSamplerBuilder _builder;
//   set builder(AnimatedSamplerBuilder value) {
//     if (value == builder) {
//       return;
//     }
//     _builder = value;
//     markNeedsCompositedLayerUpdate();
//   }
//
//   bool get enabled => _enabled;
//   bool _enabled;
//   set enabled(bool value) {
//     if (value == enabled) {
//       return;
//     }
//     _enabled = value;
//     markNeedsPaint();
//     markNeedsCompositingBitsUpdate();
//   }
//
//   @override
//   bool get isRepaintBoundary => alwaysNeedsCompositing;
//
//   @override
//   bool get alwaysNeedsCompositing => enabled;
//
//   @override
//   void paint(PaintingContext context, Offset offset) {
//     if (size.isEmpty) {
//       return;
//     }
//     assert(!_enabled || offset == Offset.zero);
//     return super.paint(context, offset);
//   }
// }
//
// class _SamplerBuilderLayer extends OffsetLayer {
//   _SamplerBuilderLayer(this._callback);
//
//   ui.Picture? _lastPicture;
//
//   Size get size => _size;
//   Size _size = Size.zero;
//   set size(Size value) {
//     if (value == size) {
//       return;
//     }
//     _size = value;
//     markNeedsAddToScene();
//   }
//
//   double get devicePixelRatio => _devicePixelRatio;
//   double _devicePixelRatio = 1.0;
//   set devicePixelRatio(double value) {
//     if (value == devicePixelRatio) {
//       return;
//     }
//     _devicePixelRatio = value;
//     markNeedsAddToScene();
//   }
//
//   AnimatedSamplerBuilder get callback => _callback;
//   AnimatedSamplerBuilder _callback;
//   set callback(AnimatedSamplerBuilder value) {
//     if (value == callback) {
//       return;
//     }
//     _callback = value;
//     markNeedsAddToScene();
//   }
//
//   ui.Image _buildChildScene(Rect bounds, double pixelRatio) {
//     final ui.SceneBuilder builder = ui.SceneBuilder();
//     final Matrix4 transform = Matrix4.diagonal3Values(
//       pixelRatio,
//       pixelRatio,
//       1,
//     );
//     builder.pushTransform(transform.storage);
//     addChildrenToScene(builder);
//     builder.pop();
//     return builder.build().toImageSync(
//           (pixelRatio * bounds.width).ceil(),
//           (pixelRatio * bounds.height).ceil(),
//         );
//   }
//
//   @override
//   void dispose() {
//     _lastPicture?.dispose();
//     super.dispose();
//   }
//
//   @override
//   void addToScene(ui.SceneBuilder builder) {
//     if (size.isEmpty) return;
//     final ui.Image image = _buildChildScene(
//       offset & size,
//       devicePixelRatio,
//     );
//     final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     try {
//       callback(image, size, canvas);
//     } finally {
//       image.dispose();
//     }
//     final ui.Picture picture = pictureRecorder.endRecording();
//     _lastPicture?.dispose();
//     _lastPicture = picture;
//     builder.addPicture(offset, picture);
//   }
// }
