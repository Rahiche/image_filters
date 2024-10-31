import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_filters/external/utils/mobile_frame.dart';

class SelectiveFocus extends StatefulWidget {
  const SelectiveFocus({super.key});

  @override
  State<SelectiveFocus> createState() => _SelectiveFocusState();
}

class _SelectiveFocusState extends State<SelectiveFocus> {
  @override
  Widget build(BuildContext context) {
    return const MobileFrame(child: InteractiveImagePage());
  }
}

class InteractiveImagePage extends StatefulWidget {
  const InteractiveImagePage({super.key});

  @override
  State<InteractiveImagePage> createState() => _InteractiveImagePageState();
}

class _InteractiveImagePageState extends State<InteractiveImagePage> {
  Offset? _position;
  ui.Image? _image;
  static const imageUrl = 'https://i.imgur.com/PVxynOu.png';

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final completer = Completer<ui.Image>();
      final imageStream =
          const NetworkImage(imageUrl).resolve(ImageConfiguration.empty);

      imageStream.addListener(ImageStreamListener(
        (info, _) => completer.complete(info.image),
        onError: (error, _) => completer.completeError(error),
      ));

      _image = await completer.future;
      setState(() {});
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
  }

  void _updateInteraction(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(globalPosition);

    setState(() {
      _position = Offset(
        (localPos.dx / box.size.width).clamp(0.0, 1.0),
        ((localPos.dy - InteractiveImagePainter.radius) / box.size.height)
            .clamp(0.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Image')),
      body: Center(
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          clipBehavior: Clip.antiAlias,
          child: _image == null
              ? const CircularProgressIndicator()
              : GestureDetector(
                  onPanStart: (d) => _updateInteraction(d.globalPosition),
                  onPanUpdate: (d) => _updateInteraction(d.globalPosition),
                  onTapDown: (d) => _updateInteraction(d.globalPosition),
                  child: CustomPaint(
                    size: Size(
                        _image!.width.toDouble(), _image!.height.toDouble()),
                    painter: InteractiveImagePainter(
                      image: _image!,
                      position: _position,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class InteractiveImagePainter extends CustomPainter {
  final ui.Image image;
  final Offset? position;
  static const radius = 50.1;

  const InteractiveImagePainter({required this.image, required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw original image
    canvas.drawImage(image, Offset.zero, Paint());

    // Apply blur and grayscale effect layer
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());

    canvas.drawImage(
      image,
      Offset.zero,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20)
        ..colorFilter = const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
    );

    // Draw clear circle at interaction point
    if (position != null) {
      canvas.drawCircle(
        Offset(position!.dx * size.width, position!.dy * size.height),
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(position!.dx * size.width, position!.dy * size.height),
            radius,
            [Colors.transparent, Colors.blue],
          )
          ..blendMode = BlendMode.dstIn,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(InteractiveImagePainter oldDelegate) =>
      image != oldDelegate.image || position != oldDelegate.position;
}
