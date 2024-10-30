import 'package:flutter/material.dart';
import 'package:image_filters/external/projects/projects_page.dart';
import 'package:image_filters/external/utils/mobile_frame.dart';

class RiveoPageCurlDemo extends StatefulWidget {
  const RiveoPageCurlDemo({super.key});

  @override
  State<RiveoPageCurlDemo> createState() => _RiveoPageCurlDemoState();
}

class _RiveoPageCurlDemoState extends State<RiveoPageCurlDemo> {
  @override
  Widget build(BuildContext context) {
    return const MobileFrame(child: RiveoProjectsPage());
  }
}
