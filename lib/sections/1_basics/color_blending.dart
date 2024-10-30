import 'package:flutter/material.dart';
import 'dart:ui';

class ColorBlendControls extends StatefulWidget {
  final Function(ImageFilter) onFilterChanged;

  const ColorBlendControls({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<ColorBlendControls> createState() => _ColorBlendControlsState();
}

class _ColorBlendControlsState extends State<ColorBlendControls> {
  Color blendColor = Colors.blue;
  double opacity = 0.5;
  BlendMode currentBlendMode = BlendMode.srcOver;

  // Preset colors list
  final List<Color> presetColors = [
    Colors.red,
    Colors.purple,
    Colors.indigo,
    Colors.cyan,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.deepOrange,
    Colors.grey,
    Colors.black,
    Colors.white,
  ];

  void _updateFilter() {
    final Color colorWithOpacity = blendColor.withValues(alpha: opacity);
    final colorFilter = ColorFilter.mode(
      colorWithOpacity,
      currentBlendMode,
    );

    widget.onFilterChanged(colorFilter);
  }

  Widget _buildColorGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Color',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: presetColors.length,
            itemBuilder: (context, index) {
              final color = presetColors[index];
              final isSelected = color == blendColor;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    blendColor = color;
                  });
                  _updateFilter();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: blendColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildBlendModeGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Blend Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 4,
            ),
            itemCount: BlendMode.values.length,
            itemBuilder: (context, index) {
              final mode = BlendMode.values[index];
              final isSelected = mode == currentBlendMode;

              return InkWell(
                onTap: () {
                  setState(() {
                    currentBlendMode = mode;
                  });
                  _updateFilter();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color:
                        isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
                  ),
                  child: Row(
                    children: [
                      Radio<BlendMode>(
                        value: mode,
                        groupValue: currentBlendMode,
                        onChanged: (BlendMode? value) {
                          if (value != null) {
                            setState(() {
                              currentBlendMode = value;
                            });
                            _updateFilter();
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          mode.toString().split('.').last,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColorGrid(),
        const SizedBox(height: 24),
        const Text('Opacity', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: opacity,
          min: 0,
          max: 1,
          divisions: 100,
          label: '${(opacity * 100).toStringAsFixed(0)}%',
          onChanged: (value) {
            setState(() {
              opacity = value;
            });
            _updateFilter();
          },
        ),
        const SizedBox(height: 24),
        _buildBlendModeGrid(),
      ],
    );
  }
}
