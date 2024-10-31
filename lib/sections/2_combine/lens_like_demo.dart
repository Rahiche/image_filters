import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class LensLikeDemo extends StatefulWidget {
  const LensLikeDemo({super.key});

  @override
  State<LensLikeDemo> createState() => _LensLikeDemoState();
}

class _LensLikeDemoState extends State<LensLikeDemo> {
  @override
  Widget build(BuildContext context) {
    return const ImageFilterDemo();
  }
}

class ImageFilterDemo extends StatefulWidget {
  const ImageFilterDemo({super.key});

  @override
  _ImageFilterDemoState createState() => _ImageFilterDemoState();
}

class _ImageFilterDemoState extends State<ImageFilterDemo> {
  double _blurValue = 5.0;
  double _dilateValue = 2.0;
  double _erodeValue = 2.0;
  bool _isBlurOuter = true;
  bool _isDilateEnabled = true;
  bool _isErodeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Filter Demo')),
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: ImageFilterWidget(
                imageUrl: "https://picsum.photos/id/112/400/600",
                blurSigma: _blurValue,
                dilateAmount: _dilateValue,
                erodeAmount: _erodeValue,
                isBlurOuter: _isBlurOuter,
                isDilateEnabled: _isDilateEnabled,
                isErodeEnabled: _isErodeEnabled,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSliderWithLabel(
                      'Blur', _blurValue, 0, 20, (value) => _blurValue = value),
                  _buildSwitchRow('Blur is:', _isBlurOuter,
                      (value) => _isBlurOuter = value, 'Outer', 'Inner'),
                  _buildSliderWithLabel('Dilate', _dilateValue, 0.5, 50,
                      (value) => _dilateValue = value,
                      enabled: _isDilateEnabled),
                  _buildSwitchRow(
                      'Dilate enabled:', _isDilateEnabled, _onDilateSwitch),
                  _buildSliderWithLabel('Erode', _erodeValue, 0.5, 50,
                      (value) => _erodeValue = value,
                      enabled: _isErodeEnabled),
                  _buildSwitchRow(
                      'Erode enabled:', _isErodeEnabled, _onErodeSwitch),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _resetValues,
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: _applyLensBlur,
                        child: const Text('Lens Blur'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderWithLabel(String label, double value, double min,
      double max, ValueChanged<double> onChanged,
      {bool enabled = true}) {
    return Column(
      children: [
        Text('$label: ${value.toStringAsFixed(1)}'),
        Slider(
          value: value,
          min: 0,
          max: max,
          divisions: ((max - min) * 2).toInt(),
          onChanged:
              enabled ? (value) => setState(() => onChanged(value)) : null,
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged,
      [String? trueText, String? falseText]) {
    return Row(
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: (value) => setState(() => onChanged(value)),
        ),
        if (trueText != null && falseText != null)
          Text(value ? trueText : falseText),
      ],
    );
  }

  void _onDilateSwitch(bool value) {
    _isDilateEnabled = value;
    if (value && _isErodeEnabled) {
      _isErodeEnabled = false;
    }
  }

  void _onErodeSwitch(bool value) {
    _isErodeEnabled = value;
    if (value && _isDilateEnabled) {
      _isDilateEnabled = false;
    }
  }

  void _resetValues() {
    setState(() {
      _blurValue = 0.0;
      _dilateValue = 0.0;
      _erodeValue = 0.0;
      _isBlurOuter = true;
      _isDilateEnabled = true;
      _isErodeEnabled = false;
    });
  }

  void _applyLensBlur() {
    setState(() {
      _blurValue = 3.0;
      _dilateValue = 5.0;
      _erodeValue = 0.0;
      _isBlurOuter = true;
      _isDilateEnabled = true;
      _isErodeEnabled = false;
    });
  }
}

class ImageFilterWidget extends StatelessWidget {
  final String imageUrl;
  final double blurSigma;
  final double dilateAmount;
  final double erodeAmount;
  final bool isBlurOuter;
  final bool isDilateEnabled;
  final bool isErodeEnabled;

  const ImageFilterWidget({
    super.key,
    required this.imageUrl,
    required this.blurSigma,
    required this.dilateAmount,
    required this.erodeAmount,
    required this.isBlurOuter,
    required this.isDilateEnabled,
    required this.isErodeEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final blurFilter = ui.ImageFilter.blur(
      sigmaX: blurSigma,
      sigmaY: blurSigma,
      tileMode: TileMode.decal,
    );
    final morphologyFilter = _getMorphologyFilter();

    return ImageFiltered(
      imageFilter: ui.ImageFilter.compose(
        outer: isBlurOuter ? blurFilter : morphologyFilter,
        inner: isBlurOuter ? morphologyFilter : blurFilter,
      ),
      child: Image.network(
        imageUrl,
        alignment: Alignment.center,
      ),
    );
  }

  ui.ImageFilter _getMorphologyFilter() {
    if (isDilateEnabled) {
      return ui.ImageFilter.dilate(
        radiusX: dilateAmount,
        radiusY: dilateAmount,
      );
    } else if (isErodeEnabled) {
      return ui.ImageFilter.erode(radiusX: erodeAmount, radiusY: erodeAmount);
    } else {
      return ui.ImageFilter.blur(
        sigmaX: 0,
        sigmaY: 0,
      ); // No-op filter
    }
  }
}
