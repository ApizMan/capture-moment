import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capture_moment/constant.dart';
import 'package:capture_moment/screens/photo/components/photo_screen_body.dart';
import 'package:flutter/material.dart';

class PhotoScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const PhotoScreen({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
          return exit(0);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kPrimaryColor,
          body: PhotoScreenBody(cameras: cameras),
        ),
      ),
    );
  }
}
