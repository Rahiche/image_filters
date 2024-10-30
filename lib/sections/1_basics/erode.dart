import 'dart:ui';
import 'package:flutter/material.dart';

class ErodeControls extends StatefulWidget {
  final Function(ImageFilter) onFilterChanged;

  const ErodeControls({super.key, required this.onFilterChanged});

  @override
  _ErodeControlsState createState() => _ErodeControlsState();
}

class _ErodeControlsState extends State<ErodeControls> {
  double radiusX = 1;
  double radiusY = 1;

  void _updateFilter() {
    final filter = ImageFilter.erode(
      radiusX: radiusX,
      radiusY: radiusY,
    );
    widget.onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Radius X: ${radiusX.toInt()}'),
        Slider(
          value: radiusX,
          min: 1,
          max: 20,
          divisions: 19,
          onChanged: (value) {
            setState(() {
              radiusX = value;
              _updateFilter();
            });
          },
        ),
        Text('Radius Y: ${radiusY.toInt()}'),
        Slider(
          value: radiusY,
          min: 1,
          max: 20,
          divisions: 19,
          onChanged: (value) {
            setState(() {
              radiusY = value;
              _updateFilter();
            });
          },
        ),
      ],
    );
  }
}
