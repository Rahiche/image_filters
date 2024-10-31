import 'dart:ui' as ui;
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

// First, let's create a class to hold our animation values
class GradientAnimationState {
  final double gradientRadius;
  final double focalRadius;
  final double centerX;
  final double centerY;

  const GradientAnimationState({
    required this.gradientRadius,
    required this.focalRadius,
    required this.centerX,
    required this.centerY,
  });

  // Lerp method to handle interpolation
  static GradientAnimationState lerp(
    GradientAnimationState begin,
    GradientAnimationState end,
    double t,
  ) {
    return GradientAnimationState(
      gradientRadius:
          ui.lerpDouble(begin.gradientRadius, end.gradientRadius, t)!,
      focalRadius: ui.lerpDouble(begin.focalRadius, end.focalRadius, t)!,
      centerX: ui.lerpDouble(begin.centerX, end.centerX, t)!,
      centerY: ui.lerpDouble(begin.centerY, end.centerY, t)!,
    );
  }
}

class _InteractiveImagePageState extends State<InteractiveImagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _currentAnimationIndex;

  // List of preset animations using the new class
  final List<GradientAnimationState> _animationPresets = [
    // top center
    const GradientAnimationState(
      gradientRadius: 400.0,
      focalRadius: 290.0,
      centerX: 0.5,
      centerY: 0.0,
    ),
    const GradientAnimationState(
      gradientRadius: 200.0,
      focalRadius: 190.0,
      centerX: 0.5,
      centerY: 0.0,
    ),
    const GradientAnimationState(
      gradientRadius: 810.0,
      focalRadius: 190.0,
      centerX: 0.5,
      centerY: 0.0,
    ),
    const GradientAnimationState(
      gradientRadius: 354.0,
      focalRadius: 108.0,
      centerX: 0.1,
      centerY: 0.5,
    ),
    // refresh button
    const GradientAnimationState(
      gradientRadius: 347.0,
      focalRadius: 290.0,
      centerX: 1.0,
      centerY: 0.0,
    ),
    // add button
    const GradientAnimationState(
      gradientRadius: 800.0,
      focalRadius: 345.0,
      centerX: 1.0,
      centerY: 1.0,
    ),
    // empty
    const GradientAnimationState(
      gradientRadius: 4000.0,
      focalRadius: 2900.0,
      centerX: 1.0,
      centerY: 1.0,
    ),
  ];

  bool isInteracting = false;
  late GradientAnimationState currentState;
  List<Color> gradientColors = [Colors.transparent, Colors.black];
  List<double> gradientStops = [0.0, 1.0];

  @override
  void initState() {
    super.initState();
    currentState = _animationPresets[0];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2200),
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

      final springValue = Curves.easeInOut.transform(
        _animationController.value,
      );

      setState(() {
        currentState = GradientAnimationState.lerp(
          currentPreset,
          nextPreset,
          springValue,
        );
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Container(
              decoration: const BoxDecoration(),
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

                  final blurredPaint = Paint()
                    ..imageFilter = ui.ImageFilter.blur(
                      sigmaX: 30,
                      sigmaY: 30,
                      tileMode: TileMode.mirror,
                    );

                  canvas.drawImage(image, Offset.zero, blurredPaint);

                  final adjustedPosition = Offset(
                    (currentState.centerX * width),
                    (currentState.centerY * height),
                  );

                  final gradient = ui.Gradient.radial(
                    adjustedPosition,
                    currentState.gradientRadius,
                    gradientColors,
                    gradientStops,
                    TileMode.clamp,
                    Matrix4.identity().storage,
                    adjustedPosition,
                    currentState.focalRadius,
                  );

                  final gradientPaint = Paint()
                    ..shader = gradient
                    ..blendMode = BlendMode.dstIn;

                  canvas.drawRect(rect, gradientPaint);
                  canvas.restore();
                },
                child: InteractiveImage(
                  onInteractionUpdate: (double x, double y) {
                    if (!isInteracting) {
                      setState(() {
                        isInteracting = true;
                      });
                      _animateToNextPreset();
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
  final Function(double x, double y) onInteractionUpdate;
  final Function() onInteractionEnd;

  const InteractiveImage({
    super.key,
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
      username: "nature_explorer",
      imageUrl: "https://i.imgur.com/ef1tEAM.jpeg",
      caption: "Discovering hidden treasures in nature 🌿",
      likes: 342,
      comments: [
        "This place looks magical!",
        "Where is this located?",
        "The colors are incredible!"
      ],
    ),
    SocialFeedPost(
      username: "urban_photographer",
      imageUrl: "https://i.imgur.com/BMD01oG.png",
      caption: "City lights and urban nights 🌃",
      likes: 567,
      comments: [
        "Perfect composition!",
        "Love the urban vibes",
        "This is stunning!"
      ],
    ),
    SocialFeedPost(
      username: "adventure_seeker",
      imageUrl: "https://i.imgur.com/H7dxIit.png",
      caption: "Living life on the edge 🏔️",
      likes: 891,
      comments: [
        "This is breathtaking!",
        "Stay safe out there!",
        "Need to visit this place"
      ],
    ),
    SocialFeedPost(
      username: "creative_soul",
      imageUrl: "https://i.imgur.com/u0Da4BS.png",
      caption: "Art is everywhere you look 🎨",
      likes: 423,
      comments: [
        "Such an artistic shot",
        "The perspective is everything",
        "Keep creating!"
      ],
    ),
    SocialFeedPost(
      username: "wanderlust_diary",
      imageUrl: "https://i.imgur.com/3QougGr.png",
      caption: "Lost in the moment ✨",
      likes: 756,
      comments: [
        "This is pure magic",
        "Your adventures inspire me",
        "Beautiful capture!"
      ],
    ),
    SocialFeedPost(
      username: "lifestyle_chronicles",
      imageUrl: "https://i.imgur.com/ea9Ug6E.png",
      caption: "Making memories that last forever 💫",
      likes: 634,
      comments: [
        "Living your best life!",
        "This is goals",
        "Can't wait to see more"
      ],
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
