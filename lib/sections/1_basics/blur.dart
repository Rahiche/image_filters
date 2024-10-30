import 'dart:ui';

import 'package:flutter/material.dart';

class BlurControls extends StatefulWidget {
  final void Function(ImageFilter) onFilterChanged;

  const BlurControls({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<BlurControls> createState() => _BlurControlsState();
}

class _BlurControlsState extends State<BlurControls> {
  double sigmaX = 0.0;
  double sigmaY = 0.0;
  TileMode tileMode = TileMode.clamp;

  void _updateFilter() {
    final filter = ImageFilter.blur(
      sigmaX: sigmaX,
      sigmaY: sigmaY,
      tileMode: tileMode,
    );
    widget.onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sigma X: ${sigmaX.toStringAsFixed(1)}'),
        Slider(
          value: sigmaX,
          max: 20.0,
          onChanged: (value) {
            setState(() => sigmaX = value);
            _updateFilter();
          },
        ),
        Text('Sigma Y: ${sigmaY.toStringAsFixed(1)}'),
        Slider(
          value: sigmaY,
          max: 20.0,
          onChanged: (value) {
            setState(() => sigmaY = value);
            _updateFilter();
          },
        ),
        const SizedBox(height: 16),
        const Text('Tile Mode:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: TileMode.values.map((mode) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<TileMode>(
                  value: mode,
                  groupValue: tileMode,
                  onChanged: (TileMode? value) {
                    if (value != null) {
                      setState(() => tileMode = value);
                      _updateFilter();
                    }
                  },
                ),
                Text(mode.name.toUpperCase()),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
