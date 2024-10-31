import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShaderMaskDemo extends StatefulWidget {
  const ShaderMaskDemo({super.key});

  @override
  State<ShaderMaskDemo> createState() => _ShaderMaskDemoState();
}

class _ShaderMaskDemoState extends State<ShaderMaskDemo> {
  @override
  Widget build(BuildContext context) {
    return const ShaderMaskDemoContent();
  }
}

class ShaderMaskDemoContent extends StatefulWidget {
  static const String _imageUrl = 'https://i.imgur.com/sHuAqc7.png';
  static const double _blurSigma = 15.0;
  static const double _gradientStop1 = 0.4;
  static const double _gradientStop2 = 0.75;

  const ShaderMaskDemoContent({super.key});

  @override
  _ShaderMaskDemoContentState createState() => _ShaderMaskDemoContentState();
}

class _ShaderMaskDemoContentState extends State<ShaderMaskDemoContent> {
  bool _showBackgroundImage = true;
  bool _showBlurredOverlay = true;
  bool _showShaderMask = true;
  bool _showBackdropFilter = true;
  bool _useCustomBlurredImage = true;
  double _blurSigma = ShaderMaskDemoContent._blurSigma;
  double _gradientStop1 = ShaderMaskDemoContent._gradientStop1;
  double _gradientStop2 = ShaderMaskDemoContent._gradientStop2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ClipRect(
            child: Center(
              child: SizedBox(
                width: 400,
                height: 300,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (_showBackgroundImage) _buildBackgroundImage(),
                    if (_showBlurredOverlay) _buildBlurredOverlay(),
                  ],
                ),
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return CachedNetworkImage(
      imageUrl: ShaderMaskDemoContent._imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _buildBlurredOverlay() {
    Widget child = _useCustomBlurredImage
        ? _buildBackgroundImage()
        : Container(color: Colors.transparent);

    if (_showShaderMask) {
      child = ShaderMask(
        shaderCallback: (rect) => _createGradientShader(rect),
        blendMode: BlendMode.dstOut,
        child: child,
      );
    }

    if (_showBackdropFilter) {
      child = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: child,
      );
    }

    return child;
  }

  Shader _createGradientShader(Rect rect) {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: const [Colors.black, Colors.transparent],
      stops: [_gradientStop1, _gradientStop2],
    ).createShader(rect);
  }

  Widget _buildControls() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _resetAllFlags,
              child: const Text('Reset All'),
            ),
            ElevatedButton(
              onPressed: _setPresetFlags,
              child: const Text('Set Preset'),
            ),
            ElevatedButton(
              onPressed: _setPreset2Flags,
              child: const Text('Set Preset 2'),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('Show Background Image'),
          value: _showBackgroundImage,
          onChanged: (value) {
            setState(() {
              _showBackgroundImage = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Show Blurred Overlay'),
          value: _showBlurredOverlay,
          onChanged: (value) {
            setState(() {
              _showBlurredOverlay = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Show Shader Mask'),
          value: _showShaderMask,
          onChanged: (value) {
            setState(() {
              _showShaderMask = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Show Backdrop Filter'),
          value: _showBackdropFilter,
          onChanged: (value) {
            setState(() {
              _showBackdropFilter = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Use Custom Blurred Image'),
          value: _useCustomBlurredImage,
          onChanged: (value) {
            setState(() {
              _useCustomBlurredImage = value;
            });
          },
        ),
        ListTile(
          title: const Text('Blur Sigma'),
          subtitle: Slider(
            value: _blurSigma,
            min: 0,
            max: 30,
            divisions: 30,
            label: _blurSigma.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _blurSigma = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Gradient Stop 1'),
          subtitle: Slider(
            value: _gradientStop1,
            min: 0,
            max: 1,
            divisions: 20,
            label: _gradientStop1.toStringAsFixed(2),
            onChanged: (value) {
              setState(() {
                _gradientStop1 = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Gradient Stop 2'),
          subtitle: Slider(
            value: _gradientStop2,
            min: 0,
            max: 1,
            divisions: 20,
            label: _gradientStop2.toStringAsFixed(2),
            onChanged: (value) {
              setState(() {
                _gradientStop2 = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void _resetAllFlags() {
    setState(() {
      _showBackgroundImage = true;
      _showBlurredOverlay = true;
      _showShaderMask = true;
      _showBackdropFilter = true;
      _useCustomBlurredImage = false;
      _blurSigma = ShaderMaskDemoContent._blurSigma;
      _gradientStop1 = ShaderMaskDemoContent._gradientStop1;
      _gradientStop2 = ShaderMaskDemoContent._gradientStop2;
    });
  }

  void _setPresetFlags() {
    setState(() {
      _showBackdropFilter = true;
      _showBackgroundImage = true;
      _showBlurredOverlay = true;
      _showShaderMask = true;
      _useCustomBlurredImage = true;
      _showBlurredOverlay = true;
      _showShaderMask = true;
      _useCustomBlurredImage = true;
    });
  }

  void _setPreset2Flags() {
    _showBackgroundImage = false;
    _showBlurredOverlay = false;
    _showShaderMask = false;
    _showBackdropFilter = false;
    _useCustomBlurredImage = false;
    _blurSigma = ShaderMaskDemoContent._blurSigma;
    _gradientStop1 = ShaderMaskDemoContent._gradientStop1;
    _gradientStop2 = ShaderMaskDemoContent._gradientStop2;
    setState(() {
      _showBlurredOverlay = true;
      _showShaderMask = true;
      _useCustomBlurredImage = true;
    });
  }
}
