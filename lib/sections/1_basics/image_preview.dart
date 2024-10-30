import 'dart:ui';

import 'package:flutter/material.dart';

class FilteredImageWidget extends StatefulWidget {
  const FilteredImageWidget({super.key, required this.filter});
  final ImageFilter filter;

  @override
  State<FilteredImageWidget> createState() => _FilteredImageWidgetState();
}

class _FilteredImageWidgetState extends State<FilteredImageWidget> {
  int _selectedImageIndex = 0;

  final List<String> _imagePaths = [
    'assets/images/pumpkin_1.jpg',
    'assets/images/pumpkin_2.jpg',
    'assets/images/pumpkin_3.png',
    'assets/images/pumpkin_4.jpg',
  ];

  ImageFilter getCurrentFilter() {
    return widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Image selection
        Center(
          child: SizedBox(
            height: 50,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: List.generate(
                _imagePaths.length,
                (index) {
                  return SizedBox(
                    width: 200,
                    child: RadioListTile<int>(
                      title: Text('Image ${index + 1}'),
                      value: index,
                      groupValue: _selectedImageIndex,
                      onChanged: (value) {
                        setState(
                          () {
                            _selectedImageIndex = value!;
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Right side - Image preview
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ClipRect(
                child: ImageFiltered(
                  imageFilter: getCurrentFilter(),
                  child: Image.asset(
                    _imagePaths[_selectedImageIndex],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Error loading image');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
