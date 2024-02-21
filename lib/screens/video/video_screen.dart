import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capture_moment/constant.dart';
import 'package:capture_moment/screens/video/components/video_screen_body.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const VideoScreen({
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
          body: VideoScreenBody(cameras: cameras),
        ),
      ),
    );
  }
}
