import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_filters/external/utils/mobile_frame.dart';
import 'package:image_filters/live_coding/onboarding.dart';

class BackdropFilterDemo extends StatefulWidget {
  const BackdropFilterDemo({super.key});

  @override
  State<BackdropFilterDemo> createState() => _BackdropFilterDemoState();
}

class _BackdropFilterDemoState extends State<BackdropFilterDemo> {
  final backdropKey = BackdropKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true,
      home: Stack(
        children: [
          SocialMediaFeed(),
          Positioned(
            bottom: 0,
            top: 0,
            right: 0,
            width: 100,
            child: buildClipRect2(),
          ),
          Positioned(
            bottom: 0,
            top: 0,
            left: 0,
            width: 100,
            child: buildClipRect2(),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: buildClipRect(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: buildClipRect(),
          ),
        ],
      ),
    );
  }

  ClipRect buildClipRect2() {
    return ClipRect(
      child: BackdropFilter(
        backdropGroupKey: backdropKey,
        filter: ImageFilter.blur(
          sigmaX: 40,
          sigmaY: 40,
          tileMode: TileMode.clamp,
        ),
        child: Container(width: 100),
      ),
    );
  }

  ClipRect buildClipRect() {
    return ClipRect(
      child: BackdropFilter(
        backdropGroupKey: backdropKey,
        filter: ImageFilter.blur(
          sigmaX: 40,
          sigmaY: 40,
          tileMode: TileMode.clamp,
        ),
        child: Container(height: 200),
      ),
    );
  }
}
//
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class BackdropFilterDemo extends StatelessWidget {
//   const BackdropFilterDemo({super.key});
//
//   static final listKey = BackdropKey();
//   static final overlayKey = BackdropKey();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       showPerformanceOverlay: true,
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             ListView.builder(
//               itemCount: 120, // 60 pairs of red and blue containers
//               itemBuilder: (context, index) {
//                 return Container(
//                   height: 100,
//                   color: index % 2 == 0 ? Colors.red : Colors.blue,
//                 );
//               },
//             ),
//             Center(
//               child: Container(
//                 width: 400,
//                 height: 400,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black),
//                 ),
//                 child: Image.network('https://picsum.photos/400'),
//               ),
//             ),
//             ListView.separated(
//               separatorBuilder: (_, __) => const SizedBox(height: 8),
//               itemBuilder: (context, index) => BlurEffect(
//                 backdropKey: listKey,
//                 child: SizedBox(
//                   height: 50,
//                   child: Center(
//                     child: Text(index.toString(),
//                         style: const TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ),
//               itemCount: 200,
//             ),
//             Positioned.fill(
//               bottom: null,
//               child: BlurEffect(
//                 backdropKey: overlayKey,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: MediaQuery.of(context).viewPadding.top,
//                   ),
//                   child: const SizedBox(height: 45),
//                 ),
//               ),
//             ),
//             Positioned.fill(
//               top: null,
//               child: BlurEffect(
//                 backdropKey: overlayKey,
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: MediaQuery.of(context).viewPadding.bottom,
//                   ),
//                   child: const SizedBox(height: 50),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class BlurEffect extends StatelessWidget {
//   final Widget child;
//
//   const BlurEffect({
//     required this.child,
//     required this.backdropKey,
//     super.key,
//   });
//
//   final BackdropKey backdropKey;
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRect(
//       child: BackdropFilter(
//         backdropGroupKey: backdropKey,
//         filter: ImageFilter.blur(
//           sigmaX: 40,
//           sigmaY: 40,
//         ),
//         child: DecoratedBox(
//           decoration: BoxDecoration(color: Colors.black.withValues(alpha: .65)),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
