import 'package:flutter/material.dart';
import 'package:image_filters/sections/1_basics/blur.dart';
import 'package:image_filters/sections/1_basics/color_blending.dart';
import 'package:image_filters/sections/1_basics/color_matrix.dart';
import 'package:image_filters/sections/1_basics/dilate.dart';
import 'package:image_filters/sections/1_basics/erode.dart';
import 'package:image_filters/sections/1_basics/matrix.dart';
import 'dart:ui';
import 'image_preview.dart';

class BasicImageFilters extends StatefulWidget {
  const BasicImageFilters({super.key});

  @override
  State<BasicImageFilters> createState() => _BasicImageFiltersState();
}

class _BasicImageFiltersState extends State<BasicImageFilters> {
  String selectedFilter = 'blur';
  final filters = [
    'blur',
    'color matrix',
    'matrix',
    'erode',
    'dilate',
    'color blend'
  ];

  ImageFilter currentFilter = ImageFilter.blur();

  void _updateFilter(ImageFilter filter) {
    setState(() {
      currentFilter = filter;
    });
  }

  Widget _buildCurrentControls() {
    switch (selectedFilter) {
      case 'blur':
        return BlurControls(onFilterChanged: _updateFilter);
      case 'color matrix':
        return ColorMatrixControls(onFilterChanged: _updateFilter);
      case 'matrix':
        return MatrixControls(onFilterChanged: _updateFilter);
      case 'erode':
        return ErodeControls(onFilterChanged: _updateFilter);
      case 'dilate':
        return DilateControls(onFilterChanged: _updateFilter);
      case 'color blend':
        return ColorBlendControls(onFilterChanged: _updateFilter);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...filters.map(
                    (filter) => RadioListTile(
                      title: Text(filter),
                      value: filter,
                      groupValue: selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value.toString();
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Adjust Parameters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildCurrentControls(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: FilteredImageWidget(filter: currentFilter),
        ),
      ],
    );
  }
}
