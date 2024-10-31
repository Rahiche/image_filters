import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class FlutterBlurPerformance extends StatefulWidget {
  const FlutterBlurPerformance({super.key});

  @override
  State<FlutterBlurPerformance> createState() => _FlutterBlurPerformanceState();
}

class _FlutterBlurPerformanceState extends State<FlutterBlurPerformance> {
  @override
  Widget build(BuildContext context) {
    return AnimatedImageCarousel(
      demos: [
        //Mipmaping
        DownSampleShaderWidget(
          child: Image.asset("assets/images/pumpkin_2.jpg"),
        ),
        //Gaussian Sepraple kernal
        const GaussianKernelVisualizer(),
        const GaussianKernel1DVisualizer(),
        // Lerp Hack
        ColorfulGridView(),
      ],
    );
  }
}

class DownSampleShaderWidget extends StatefulWidget {
  final Widget child;

  const DownSampleShaderWidget({Key? key, required this.child})
      : super(key: key);

  @override
  _DownSampleShaderWidgetState createState() => _DownSampleShaderWidgetState();
}

class _DownSampleShaderWidgetState extends State<DownSampleShaderWidget> {
  double _edge = 2.0;
  double _ratio = 0.1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ShaderBuilder(
            assetKey: 'shaders/down_sample.frag',
            (context, shader, child) {
              return AnimatedSampler(
                (image, size, canvas) {
                  shader
                    ..setFloat(0, size.width)
                    ..setFloat(1, size.height)
                    ..setFloat(2, _ratio)
                    ..setImageSampler(0, image);

                  canvas.drawRect(
                    Offset.zero & size,
                    Paint()..shader = shader,
                  );
                },
                child: ClipRect(child: widget.child),
              );
            },
          ),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Pixel: ${_ratio.toStringAsFixed(2)}'),
          Slider(
            value: _ratio,
            min: 0.0,
            max: 10.0,
            onChanged: (value) {
              setState(() {
                _ratio = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class AnimatedImageCarousel extends StatefulWidget {
  final List<Widget> demos;
  final Duration animationDuration;

  const AnimatedImageCarousel({
    super.key,
    this.animationDuration = const Duration(milliseconds: 300),
    required this.demos,
  });

  @override
  _AnimatedImageCarouselState createState() => _AnimatedImageCarouselState();
}

class _AnimatedImageCarouselState extends State<AnimatedImageCarousel> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage < widget.demos.length) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
          );
        }
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.demos.length,
        itemBuilder: (context, index) {
          return _buildImage(index);
        },
      ),
    );
  }

  Widget _buildImage(int index) {
    double distance = (_currentPage - index).abs();
    double scale = 1.0 - (distance * 0.3).clamp(0.0, 0.3);

    return Transform.scale(
      scale: scale,
      child: widget.demos[index],
    );
  }
}

class GaussianKernelVisualizer extends StatefulWidget {
  const GaussianKernelVisualizer({Key? key}) : super(key: key);

  @override
  _GaussianKernelVisualizerState createState() =>
      _GaussianKernelVisualizerState();
}

class _GaussianKernelVisualizerState extends State<GaussianKernelVisualizer> {
  double _sigma = 1.0;
  int _gridSize = 30;
  final TransformationController _transformationController =
      TransformationController();
  bool _showWeights = false;

  List<List<double>> _generateGaussianKernel() {
    List<List<double>> kernel =
        List.generate(_gridSize, (_) => List<double>.filled(_gridSize, 0));
    double sum = 0;

    for (int x = 0; x < _gridSize; x++) {
      for (int y = 0; y < _gridSize; y++) {
        int cx = _gridSize ~/ 2;
        int cy = _gridSize ~/ 2;
        double value = (1 / (2 * pi * _sigma * _sigma)) *
            exp(-((x - cx) * (x - cx) + (y - cy) * (y - cy)) /
                (2 * _sigma * _sigma));
        kernel[x][y] = value;
        sum += value;
      }
    }

    // Normalize the kernel
    for (int x = 0; x < _gridSize; x++) {
      for (int y = 0; y < _gridSize; y++) {
        kernel[x][y] /= sum;
      }
    }

    return kernel;
  }

  void _zoomIn() {
    _transformationController.value =
        _transformationController.value.scaled(1.2);
  }

  void _zoomOut() {
    _transformationController.value =
        _transformationController.value.scaled(1 / 1.2);
  }

  void _centerGrid() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    List<List<double>> kernel = _generateGaussianKernel();
    double maxValue = kernel.expand((list) => list).reduce(max);

    return Scaffold(
      appBar: AppBar(title: const Text('Gaussian Kernel Visualizer')),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.001,
              maxScale: 10.0,
              clipBehavior: Clip.none,
              transformationController: _transformationController,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      int x = index % _gridSize;
                      int y = index ~/ _gridSize;
                      double value = kernel[x][y];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(value / maxValue),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: _showWeights
                            ? Center(
                                child: Text(
                                  value.toStringAsFixed(4),
                                  style: const TextStyle(
                                      fontSize: 6, color: Colors.white),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Sigma: ${_sigma.toStringAsFixed(2)}'),
                Slider(
                  value: _sigma,
                  min: 0.1,
                  max: 5.0,
                  divisions: 49,
                  onChanged: (value) {
                    setState(() {
                      _sigma = value;
                    });
                  },
                ),
                Text('Kernel Size: $_gridSize x $_gridSize'),
                Slider(
                  value: _gridSize.toDouble(),
                  min: 3,
                  max: 51,
                  divisions: 48,
                  onChanged: (value) {
                    setState(() {
                      _gridSize = value.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _zoomIn,
                      child: const Text('Zoom In'),
                    ),
                    ElevatedButton(
                      onPressed: _zoomOut,
                      child: const Text('Zoom Out'),
                    ),
                    ElevatedButton(
                      onPressed: _centerGrid,
                      child: const Text('Center Grid'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Show Weights'),
                    Switch(
                      value: _showWeights,
                      onChanged: (value) {
                        setState(() {
                          _showWeights = value;
                        });
                      },
                    ),
                  ],
                ),
                Text('Kernel Center: (${_gridSize ~/ 2}, ${_gridSize ~/ 2})'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GaussianKernel1DVisualizer extends StatefulWidget {
  const GaussianKernel1DVisualizer({Key? key}) : super(key: key);

  @override
  _GaussianKernel1DVisualizerState createState() =>
      _GaussianKernel1DVisualizerState();
}

class _GaussianKernel1DVisualizerState
    extends State<GaussianKernel1DVisualizer> {
  double _sigma = 1.0;
  int _kernelSize = 15;
  bool _showWeights = false;

  List<double> _generateGaussianKernel() {
    List<double> kernel = List<double>.filled(_kernelSize, 0);
    double sum = 0;

    for (int i = 0; i < _kernelSize; i++) {
      int center = _kernelSize ~/ 2;
      double value = (1 / (sqrt(2 * pi) * _sigma)) *
          exp(-pow(i - center, 2) / (2 * _sigma * _sigma));
      kernel[i] = value;
      sum += value;
    }

    // Normalize the kernel
    for (int i = 0; i < _kernelSize; i++) {
      kernel[i] /= sum;
    }

    return kernel;
  }

  @override
  Widget build(BuildContext context) {
    List<double> kernel = _generateGaussianKernel();
    double maxValue = kernel.reduce(max);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildVerticalVisualization(kernel, maxValue),
              ),
              Expanded(
                child: _buildHorizontalVisualization(kernel, maxValue),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Sigma: ${_sigma.toStringAsFixed(2)}'),
              Slider(
                value: _sigma,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                onChanged: (value) {
                  setState(() {
                    _sigma = value;
                  });
                },
              ),
              Text('Kernel Size: $_kernelSize'),
              Slider(
                value: _kernelSize.toDouble(),
                min: 3,
                max: 51,
                divisions: 48,
                onChanged: (value) {
                  setState(() {
                    _kernelSize = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Show Weights'),
                  Switch(
                    value: _showWeights,
                    onChanged: (value) {
                      setState(() {
                        _showWeights = value;
                      });
                    },
                  ),
                ],
              ),
              Text('Kernel Center: ${_kernelSize ~/ 2}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalVisualization(List<double> kernel, double maxValue) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Vertical Visualization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildKernelCells(kernel, maxValue, isVertical: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalVisualization(List<double> kernel, double maxValue) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Horizontal Visualization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _buildKernelCells(kernel, maxValue, isVertical: false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildKernelCells(List<double> kernel, double maxValue,
      {required bool isVertical}) {
    return List.generate(
      _kernelSize,
      (index) {
        double value = kernel[index];
        return Container(
          width: isVertical ? 40 : null,
          height: isVertical ? null : 40,
          constraints: BoxConstraints(
            maxWidth: isVertical ? 40 : double.infinity,
            maxHeight: isVertical ? double.infinity : 40,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(value / maxValue),
            border: Border.all(color: Colors.black12),
          ),
          child: _showWeights
              ? Center(
                  child: RotatedBox(
                    quarterTurns: isVertical ? 3 : 0,
                    child: Text(
                      value.toStringAsFixed(4),
                      style: const TextStyle(fontSize: 8, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

(int, List<double>) linearSamplingPositions(int N) {
  if (N % 2 == 0) {
    throw ArgumentError("N must be odd");
  }

  int M = (N / 2).ceil();
  List<double> positions = List.generate(M, (i) => (2 * (i + 1) - 1) / (2 * N));

  return (M, positions);
}

class ColorfulGridView extends StatefulWidget {
  @override
  _ColorfulGridViewState createState() => _ColorfulGridViewState();
}

class _ColorfulGridViewState extends State<ColorfulGridView> {
  int _itemCount = 11; // Start with an odd number
  final Random _random = Random();
  late int _circleCount;
  late List<double> _circlePositions;

  @override
  void initState() {
    super.initState();
    _updateCirclePositions();
  }

  void _updateCirclePositions() {
    var (M, positions) = linearSamplingPositions(_itemCount);
    _circleCount = M;
    _circlePositions = positions;
  }

  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Colored squares
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _itemCount,
                shrinkWrap: true,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  return Center(
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        width: 50,
                        height: 50,
                        color: _getRandomColor(),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // White circles
              ...List.generate(_circleCount, (index) {
                return Positioned(
                  left: _circlePositions[index] * (_itemCount * 50 * 2) - 5,
                  bottom: 0,
                  top: 0,
                  child: Animate(
                    effects: [
                      ScaleEffect(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 500.milliseconds,
                        curve: Curves.easeInOut,
                      ),
                      FadeEffect(
                        begin: 0.5,
                        end: 1,
                        duration: 500.milliseconds,
                        curve: Curves.easeInOut,
                      ),
                    ],
                    onComplete: (controller) =>
                        controller.repeat(reverse: true),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Number of items: '),
              Expanded(
                child: Slider(
                  value: _itemCount.toDouble(),
                  min: 3,
                  max: 51,
                  divisions: 24,
                  label: _itemCount.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _itemCount = value.round();
                      if (_itemCount % 2 == 0) {
                        _itemCount += 1; // Ensure odd number
                      }
                      _updateCirclePositions();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
