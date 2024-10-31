import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class BlurWithPackageImage extends StatefulWidget {
  const BlurWithPackageImage({super.key});

  @override
  State<BlurWithPackageImage> createState() => _BlurWithPackageImageState();
}

class _BlurWithPackageImageState extends State<BlurWithPackageImage> {
  @override
  Widget build(BuildContext context) {
    return const GaussianBlurWidget(
      imagePath: 'assets/images/pumpkin_2.jpg',
    );
  }
}

class GaussianBlurWidget extends StatefulWidget {
  final String imagePath;

  const GaussianBlurWidget({super.key, required this.imagePath});

  @override
  State<GaussianBlurWidget> createState() => _GaussianBlurWidgetState();
}

class _GaussianBlurWidgetState extends State<GaussianBlurWidget> {
  Image? blurredImage;
  int sigma = 1;
  bool useIsolate = false;
  bool isLoading = false;
  String blurDuration = '';
  String imageSize = '';

  @override
  void initState() {
    super.initState();
    _loadImageInfo();
  }

  Future<void> _loadImageInfo() async {
    final imageBytes = await _loadImageBytes(widget.imagePath);
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      setState(() {
        imageSize = '${image.width} x ${image.height} pixels';
      });
    }
  }

  Future<void> _applyBlur() async {
    final imageBytes = await _loadImageBytes(widget.imagePath);
    setState(() => isLoading = true);

    final stopwatch = Stopwatch()..start();

    if (useIsolate) {
      blurredImage = await _applyGaussianBlurWithIsolate(imageBytes, sigma);
    } else {
      blurredImage = await _applyGaussianBlur(imageBytes);
    }

    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    blurDuration = '${duration}ms';

    setState(() => isLoading = false);
  }

  Future<Image> _applyGaussianBlurWithIsolate(
      Uint8List bytes, int sigma) async {
    final port = ReceivePort();
    final isolate = await Isolate.spawn(_blurImageEntryPoint, port.sendPort);

    final completer = Completer<Uint8List>();
    port.listen((message) {
      if (message is SendPort) {
        message.send(_BlurImageData(bytes, sigma, port.sendPort));
      } else if (message is Uint8List) {
        completer.complete(message);
        port.close();
        isolate.kill();
      }
    });

    final blurredImageBytes = await completer.future;
    return Image.memory(blurredImageBytes, gaplessPlayback: true);
  }

  Future<Image> _applyGaussianBlur(Uint8List bytes) async {
    final image = img.decodeImage(bytes)!;
    final blurredImage = img.gaussianBlur(image, radius: sigma);
    return Image.memory(img.encodePng(blurredImage));
  }

  Future<Uint8List> _loadImageBytes(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: Image.asset(widget.imagePath)),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Image Size: $imageSize"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sigma: "),
                  Slider(
                    value: sigma.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: sigma.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        sigma = value.toInt();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Use Isolate: "),
                  Switch(
                    value: useIsolate,
                    onChanged: (value) {
                      setState(() {
                        useIsolate = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _applyBlur,
                child: const Text("Apply Blur"),
              ),
              const SizedBox(height: 20),
              Text("Blur Duration: $blurDuration"),
            ],
          )),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else if (blurredImage != null)
                  Expanded(child: Center(child: blurredImage!))
                else
                  const Text("Click 'Apply Blur' to see the result"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _blurImageEntryPoint(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final data in port) {
    if (data is _BlurImageData) {
      final image = img.decodeImage(data.bytes)!;
      final blurredImage = img.gaussianBlur(image, radius: data.sigma.toInt());
      final encodedImage = img.encodePng(blurredImage);

      data.resultPort.send(Uint8List.fromList(encodedImage));
    }
  }
}

class _BlurImageData {
  final Uint8List bytes;
  final int sigma;
  final SendPort resultPort;

  _BlurImageData(this.bytes, this.sigma, this.resultPort);
}
