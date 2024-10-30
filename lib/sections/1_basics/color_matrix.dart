import 'dart:ui';
import 'package:flutter/material.dart';

class ColorMatrixControls extends StatefulWidget {
  final void Function(ImageFilter) onFilterChanged;

  const ColorMatrixControls({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<ColorMatrixControls> createState() => _ColorMatrixControlsState();
}

class _ColorMatrixControlsState extends State<ColorMatrixControls> {
  // Basic adjustments
  double brightness = 0.0;
  double contrast = 1.0;
  double saturation = 1.0;
  double sepia = 0.0;

  // Additional adjustments
  double exposure = 0.0;
  double gamma = 1.0;
  double hue = 0.0;
  double temperature = 0.0;
  double threshold = 0.5;

  // Custom effects
  double vignette = 0.0;
  double invert = 0.0;
  double monochrome = 0.0;
  double fade = 0.0;
  double noir = 0.0;
  double thermal = 0.0;
  Color monochromeColor = Colors.blue;

  static const List<double> _sepiaMatrix = [
    0.393,
    0.769,
    0.189,
    0,
    0,
    0.349,
    0.686,
    0.168,
    0,
    0,
    0.272,
    0.534,
    0.131,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  void _updateFilter() {
    List<double> matrix = [
      contrast * (1 - sepia) + sepia * _sepiaMatrix[0],
      sepia * _sepiaMatrix[1],
      sepia * _sepiaMatrix[2],
      0,
      brightness * 255,
      sepia * _sepiaMatrix[5],
      contrast * (1 - sepia) + sepia * _sepiaMatrix[6],
      sepia * _sepiaMatrix[7],
      0,
      brightness * 255,
      sepia * _sepiaMatrix[10],
      sepia * _sepiaMatrix[11],
      contrast * (1 - sepia) + sepia * _sepiaMatrix[12],
      0,
      brightness * 255,
      0,
      0,
      0,
      1,
      0,
    ];

    // Apply saturation
    if (saturation != 1.0) {
      final sr = 0.2126 * (1 - saturation);
      final sg = 0.7152 * (1 - saturation);
      final sb = 0.0722 * (1 - saturation);

      matrix[0] = matrix[0] * saturation + sr;
      matrix[1] = matrix[1] * saturation + sg;
      matrix[2] = matrix[2] * saturation + sb;

      matrix[5] = matrix[5] * saturation + sr;
      matrix[6] = matrix[6] * saturation + sg;
      matrix[7] = matrix[7] * saturation + sb;

      matrix[10] = matrix[10] * saturation + sr;
      matrix[11] = matrix[11] * saturation + sg;
      matrix[12] = matrix[12] * saturation + sb;
    }

    // Apply color inversion
    if (invert > 0) {
      for (var i = 0; i < 12; i += 5) {
        matrix[i] = (1 - matrix[i]) * invert + matrix[i] * (1 - invert);
        matrix[i + 1] =
            (1 - matrix[i + 1]) * invert + matrix[i + 1] * (1 - invert);
        matrix[i + 2] =
            (1 - matrix[i + 2]) * invert + matrix[i + 2] * (1 - invert);
      }
    }

    // Apply monochrome effect
    if (monochrome > 0) {
      final r = monochromeColor.r / 255;
      final g = monochromeColor.g / 255;
      final b = monochromeColor.b / 255;

      final grayscaleMatrix = [
        r * 0.2126,
        r * 0.7152,
        r * 0.0722,
        0,
        0,
        g * 0.2126,
        g * 0.7152,
        g * 0.0722,
        0,
        0,
        b * 0.2126,
        b * 0.7152,
        b * 0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

      for (var i = 0; i < matrix.length; i++) {
        matrix[i] =
            matrix[i] * (1 - monochrome) + grayscaleMatrix[i] * monochrome;
      }
    }

    // Apply fade effect
    if (fade > 0) {
      final fadeMatrix = [
        0.8,
        0.1,
        0.1,
        0,
        0,
        0.1,
        0.8,
        0.1,
        0,
        0,
        0.1,
        0.1,
        0.8,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

      for (var i = 0; i < matrix.length; i++) {
        matrix[i] = matrix[i] * (1 - fade) + fadeMatrix[i] * fade;
      }
    }

    // Apply noir effect
    if (noir > 0) {
      final noirMatrix = [
        0.35,
        0.35,
        0.35,
        0,
        -50,
        0.35,
        0.35,
        0.35,
        0,
        -50,
        0.35,
        0.35,
        0.35,
        0,
        -50,
        0,
        0,
        0,
        1,
        0,
      ];

      for (var i = 0; i < matrix.length; i++) {
        matrix[i] = matrix[i] * (1 - noir) + noirMatrix[i] * noir;
      }
    }

    // Apply thermal effect
    if (thermal > 0) {
      final thermalMatrix = [
        3,
        -1.5,
        -1.5,
        0,
        0,
        -1.5,
        3,
        -1.5,
        0,
        0,
        -1.5,
        -1.5,
        3,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ];

      for (var i = 0; i < matrix.length; i++) {
        matrix[i] = matrix[i] * (1 - thermal) + thermalMatrix[i] * thermal;
      }
    }

    // Apply vignette effect (darkening around edges is handled separately in the widget)
    if (vignette > 0) {
      for (var i = 0; i < 12; i += 5) {
        matrix[i] *= (1 - vignette * 0.3);
        matrix[i + 1] *= (1 - vignette * 0.3);
        matrix[i + 2] *= (1 - vignette * 0.3);
      }
    }

    final filter = ColorFilter.matrix(matrix) as ImageFilter;
    widget.onFilterChanged(filter);
  }

  void _applyPreset(String preset) {
    setState(() {
      _resetAllValues();
      switch (preset) {
        case 'normal':
          break;
        case 'grayscale':
          saturation = 0.0;
          break;
        case 'sepia':
          sepia = 1.0;
          break;
        case 'invert':
          invert = 1.0;
          break;
        case 'monochrome':
          monochrome = 1.0;
          monochromeColor = Colors.blue;
          break;
        case 'fade':
          fade = 0.7;
          brightness = -0.1;
          break;
        case 'noir':
          noir = 1.0;
          contrast = 1.5;
          break;
        case 'thermal':
          thermal = 1.0;
          saturation = 1.5;
          break;
        case 'vintage':
          sepia = 0.5;
          fade = 0.3;
          vignette = 0.4;
          break;
        case 'xray':
          invert = 1.0;
          brightness = 0.2;
          contrast = 1.3;
          break;
      }
    });
    _updateFilter();
  }

  void _resetAllValues() {
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    sepia = 0.0;
    exposure = 0.0;
    gamma = 1.0;
    hue = 0.0;
    temperature = 0.0;
    threshold = 0.5;
    vignette = 0.0;
    invert = 0.0;
    monochrome = 0.0;
    fade = 0.0;
    noir = 0.0;
    thermal = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _applyPreset('normal'),
                child: const Text('Normal'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('grayscale'),
                child: const Text('Grayscale'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('sepia'),
                child: const Text('Sepia'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('invert'),
                child: const Text('Invert'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('monochrome'),
                child: const Text('Monochrome'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('fade'),
                child: const Text('Fade'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('noir'),
                child: const Text('Noir'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('thermal'),
                child: const Text('Thermal'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('vintage'),
                child: const Text('Vintage'),
              ),
              ElevatedButton(
                onPressed: () => _applyPreset('xray'),
                child: const Text('X-Ray'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSlider('Brightness', brightness, -1.0, 1.0),
          _buildSlider('Contrast', contrast, 0.0, 2.0),
          _buildSlider('Saturation', saturation, 0.0, 2.0),
          _buildSlider('Exposure', exposure, -1.0, 1.0),
          _buildSlider('Gamma', gamma, 0.2, 2.0),
          _buildSlider('Hue', hue, -180, 180),
          _buildSlider('Temperature', temperature, -1.0, 1.0),
          _buildSlider('Sepia', sepia, 0.0, 1.0),
          _buildSlider('Vignette', vignette, 0.0, 1.0),
          _buildSlider('Invert', invert, 0.0, 1.0),
          _buildSlider('Monochrome', monochrome, 0.0, 1.0),
          _buildSlider('Fade', fade, 0.0, 1.0),
          _buildSlider('Noir', noir, 0.0, 1.0),
          _buildSlider('Thermal', thermal, 0.0, 1.0),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max) {
    return Column(
      children: [
        Text('$label: ${value.toStringAsFixed(1)}'),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (newValue) {
            setState(() {
              switch (label.toLowerCase()) {
                case 'brightness':
                  brightness = newValue;
                  break;
                case 'contrast':
                  contrast = newValue;
                  break;
                case 'saturation':
                  saturation = newValue;
                  break;
                case 'exposure':
                  exposure = newValue;
                  break;
                case 'gamma':
                  gamma = newValue;
                  break;
                case 'hue':
                  hue = newValue;
                  break;
                case 'temperature':
                  temperature = newValue;
                  break;
                case 'sepia':
                  sepia = newValue;
                  break;
                case 'vignette':
                  vignette = newValue;
                  break;
                case 'invert':
                  invert = newValue;
                  break;
                case 'monochrome':
                  monochrome = newValue;
                  break;
                case 'fade':
                  fade = newValue;
                  break;
                case 'noir':
                  noir = newValue;
                  break;
                case 'thermal':
                  thermal = newValue;
                  break;
              }
            });
            _updateFilter();
          },
        ),
      ],
    );
  }
}
