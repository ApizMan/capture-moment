import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:camera/camera.dart';
import 'package:capture_moment/constant.dart';
import 'package:capture_moment/screens/screens.dart';
import 'package:capture_moment/screens/video/video_screen.dart';
import 'package:capture_moment/theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:path/path.dart' as path;
// ignore: library_prefixes
import 'package:path_provider/path_provider.dart' as pathProvider;

class ProModeScreenBody extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ProModeScreenBody({
    super.key,
    required this.cameras,
  });

  @override
  State<ProModeScreenBody> createState() => _PhotoScreenBodyState();
}

class _PhotoScreenBodyState extends State<ProModeScreenBody> {
  final double _ratioAspect = 1.8;
  late CameraController controller;
  bool isCapturing = false;

  // For switching Camera
  int _selectedCameraIndex = 0;
  bool _isFrontCamera = false;

  // For FlashLight
  bool _isFlashOn = false;

  // For Focusing
  Offset? _focusPoint;

  // For Zoom
  double _currentZoom = 1.0;
  File? _captureImage;

  // For Making Sound
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  // For Pro Mode
  double _exposureValue = 0.0;
  ExposureMode _exposureMode = ExposureMode.auto;
  List<double> exposureOffsets = [-1.0, -0.5, 0.0, 0.5];

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Top Navigation Camera
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: const BoxDecoration(
                  color: kBlack,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _toggleFlashLight();
                      },
                      icon: _isFlashOn == false
                          ? const Icon(Icons.flash_off)
                          : const Icon(Icons.flash_on),
                      color: kWhite,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QRScanner(camera: widget.cameras.first),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      color: kWhite,
                    ),
                  ],
                ),
              ),
            ),
            // Camera part
            Positioned.fill(
              top: 50,
              bottom: _isFrontCamera == false ? 0 : 150,
              child: AspectRatio(
                aspectRatio: _ratioAspect,
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    final Offset tapPosition = details.localPosition;
                    final Offset relativeTapPosition = Offset(
                      tapPosition.dx / constraints.maxWidth,
                      tapPosition.dy / constraints.maxHeight,
                    );
                    _setFocusPoint(relativeTapPosition);
                  },
                  child: CameraPreview(controller),
                ),
              ),
            ),

            if (_focusPoint != null)
              Positioned.fill(
                top: 50,
                child: Align(
                  alignment: Alignment(
                      _focusPoint!.dx * 2 - 1, _focusPoint!.dy * 2 - 1),
                  child: Container(
                    height: 100,
                    width: 80,
                    decoration: const BoxDecoration(
                      // border: Border.all(color: kWhite, width: 2),
                      image: DecorationImage(
                          image: AssetImage('assets/images/focus.png'),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

            // Bottom Navigation Camera
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _isFrontCamera == false ? true : false,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: kWhite.withOpacity(0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Text(_currentZoom.toStringAsFixed(1)),
                        ),
                        Slider(
                          max: 10.0,
                          min: 1.0,
                          activeColor: kPrimaryColor,
                          value: _currentZoom,
                          onChanged: (dynamic value) {
                            setState(() {
                              zoomCamera(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: _isFrontCamera == false
                          ? kBlack.withOpacity(0.5)
                          : kBlack,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                              secondaryAnimation) {
                                            return VideoScreen(
                                              cameras: widget.cameras,
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 500),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Video",
                                      style: CustomTheme.normalTextStyle(
                                          color: kWhite,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PhotoScreen(
                                              cameras: widget.cameras),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Photo",
                                      style: CustomTheme.normalTextStyle(
                                          color: kWhite,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Pro Mode",
                                    style: CustomTheme.normalTextStyle(
                                        color: kPrimaryAccentColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _captureImage != null
                                            ? Container(
                                                width: 50,
                                                height: 50,
                                                child: Image.file(
                                                  _captureImage!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _capturePhoto();
                                      },
                                      child: Center(
                                        child: Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                              color: kTransparentColor,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                width: 4,
                                                color: kWhite,
                                                style: BorderStyle.solid,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      onPressed: () {
                                        _switchCamera();
                                      },
                                      icon: Icon(
                                        _isFrontCamera == true
                                            ? Icons.flip_camera_ios
                                            : Icons.camera_front,
                                        color: kWhite,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 50,
              left: 0.0,
              right: 0.0,
              child: FlutterSlider(
                values: [_exposureValue],
                min: -1.0,
                max: 1.0,
                decoration: BoxDecoration(
                  color: kBlack.withOpacity(0.4),
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  setState(() {
                    _exposureValue = lowerValue;
                  });

                  if (_exposureMode != ExposureMode.auto) {
                    setState(() {
                      _exposureMode = ExposureMode.auto;
                    });
                    controller.setExposureMode(_exposureMode);
                  }

                  controller.setExposureOffset(lowerValue);
                },
              ),
            )
          ],
        );
      },
    );
  }

  void _toggleFlashLight() {
    if (_isFlashOn) {
      controller.setFlashMode(FlashMode.off);
      setState(() {
        _isFlashOn = false;
      });
    } else {
      controller.setFlashMode(FlashMode.torch);
      setState(() {
        _isFlashOn = true;
      });
    }
  }

  void _switchCamera() async {
    // Dispose the current controller to release the camera resource
    await controller.dispose();

    // Increase or reset the selected camera index
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;

    // Initialize the new camera
    _initCamera(_selectedCameraIndex);
  }

  Future<void> _initCamera(int cameraIndex) async {
    controller =
        CameraController(widget.cameras[cameraIndex], ResolutionPreset.max);

    try {
      await controller.initialize();
      setState(() {
        if (cameraIndex == 0) {
          _isFrontCamera = false;
        } else {
          _isFrontCamera = true;
        }
      });
    } catch (e) {
      print('Error Message: ${e.toString()}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _capturePhoto() async {
    if (!controller.value.isInitialized) {
      return;
    }

    final Directory appDir =
        await pathProvider.getApplicationSupportDirectory();

    final String capturePath = path.join(appDir.path, '${DateTime.now()}.jpg');

    if (controller.value.isTakingPicture) {
      return;
    }

    try {
      setState(() {
        isCapturing = true;
      });

      final XFile captureImage = await controller.takePicture();
      String imagePath = captureImage.path;

      await GallerySaver.saveImage(imagePath);

      // Play a sound effect
      audioPlayer.open(
        Audio('assets/music/camera_shutter.mp3'),
      );
      audioPlayer.play();

      Fluttertoast.showToast(
        msg: "Photo captured and saved to the gallery",
        gravity: ToastGravity.TOP,
        backgroundColor: kPrimaryColor,
      );

      // For show Image
      final String filePath =
          '$capturePath/${DateTime.now().millisecondsSinceEpoch}.jpg';
      _captureImage = File(captureImage.path);
      _captureImage!.renameSync(filePath);
    } catch (e) {
      print('Error Message : ${e.toString()}');
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  void zoomCamera(double value) {
    setState(() {
      _currentZoom = value;
      controller.setZoomLevel(value);
    });
  }

  Future<void> _setFocusPoint(Offset point) async {
    if (controller.value.isInitialized) {
      try {
        final double x = point.dx.clamp(0.0, 1.0);
        final double y = point.dy.clamp(0.0, 1.0);
        await controller.setFocusPoint(Offset(x, y));
        await controller.setFocusMode(FocusMode.auto);
        setState(() {
          _focusPoint = Offset(x, y);
        });

        // Reset _focusPoint after a short delay to remove the square
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _focusPoint = null;
        });
      } catch (e) {
        print('Error Message: ${e.toString()}');
      }
    }
  }
}
