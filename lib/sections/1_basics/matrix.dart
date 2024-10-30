import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'dart:math' as math;

class MatrixControls extends StatefulWidget {
  final Function(ImageFilter) onFilterChanged;

  const MatrixControls({super.key, required this.onFilterChanged});

  @override
  State<MatrixControls> createState() => _MatrixControlsState();
}

class _MatrixControlsState extends State<MatrixControls> {
  // Initialize with identity matrix
  final List<double> matrixValues = [
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1
  ];

  void _updateFilter() {
    widget.onFilterChanged(ImageFilter.matrix(
      Float64List.fromList(matrixValues),
      filterQuality: FilterQuality.medium,
    ));
  }

  void _resetToIdentity() {
    setState(() {
      for (int i = 0; i < 16; i++) {
        matrixValues[i] = (i % 5 == 0) ? 1.0 : 0.0;
      }
      _updateFilter();
    });
  }

  void _scale(double scale) {
    setState(() {
      _resetToIdentity();
      matrixValues[0] = scale;
      matrixValues[5] = scale;
      matrixValues[10] = scale;
      _updateFilter();
    });
  }

  void _rotate(double degrees) {
    final radians = degrees * (math.pi / 180);
    final cos = math.cos(radians);
    final sin = math.sin(radians);

    setState(() {
      _resetToIdentity();
      matrixValues[0] = cos;
      matrixValues[1] = sin;
      matrixValues[4] = -sin;
      matrixValues[5] = cos;
      _updateFilter();
    });
  }

  void _skew(double skewX, double skewY) {
    setState(() {
      _resetToIdentity();
      matrixValues[1] = math.tan(skewX * (math.pi / 180));
      matrixValues[4] = math.tan(skewY * (math.pi / 180));
      _updateFilter();
    });
  }

  Widget _buildMatrixDisplay() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(4, (row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (col) {
              return Container(
                width: 60,
                padding: const EdgeInsets.all(4),
                child: Text(
                  matrixValues[row * 4 + col].toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matrix Transform',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMatrixDisplay(),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: _resetToIdentity,
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () => _scale(1.5),
              child: const Text('Scale 1.5x'),
            ),
            ElevatedButton(
              onPressed: () => _scale(0.5),
              child: const Text('Scale 0.5x'),
            ),
            ElevatedButton(
              onPressed: () => _rotate(45),
              child: const Text('Rotate 45°'),
            ),
            ElevatedButton(
              onPressed: () => _rotate(90),
              child: const Text('Rotate 90°'),
            ),
            ElevatedButton(
              onPressed: () => _rotate(180),
              child: const Text('Rotate 180°'),
            ),
            ElevatedButton(
              onPressed: () => _skew(30, 0),
              child: const Text('Skew X'),
            ),
            ElevatedButton(
              onPressed: () => _skew(0, 30),
              child: const Text('Skew Y'),
            ),
          ],
        ),
      ],
    );
  }
}
