import 'dart:ui';
import 'package:flutter/material.dart';

class DilateControls extends StatefulWidget {
  final Function(ImageFilter) onFilterChanged;

  const DilateControls({Key? key, required this.onFilterChanged})
      : super(key: key);

  @override
  _DilateControlsState createState() => _DilateControlsState();
}

class _DilateControlsState extends State<DilateControls> {
  double radiusX = 1;
  double radiusY = 1;

  void _updateFilter() {
    final filter = ImageFilter.dilate(
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
