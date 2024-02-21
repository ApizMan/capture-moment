import 'package:camera/camera.dart';
import 'package:capture_moment/constant.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class QRScanner extends StatefulWidget {
  final CameraDescription camera;
  const QRScanner({
    super.key,
    required this.camera,
  });

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  CameraController? _cameraController;
  QRViewController? _qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isCameraInitialized = false;
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;

  @override
  void initState() {
    _requestCameraPermission();
    super.initState();

    // Check for Android Custom Tab support.
    launcher
        .supportsMode(PreferredLaunchMode.inAppBrowserView)
        .then((bool result) {
      setState(() {
        result;
      });
    });
  }

  @override
  void dispose() {
    _qrViewController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: _isCameraInitialized
                  ? QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderRadius: 10.0,
                        borderColor: kWhite,
                        borderLength: 30.0,
                        borderWidth: 10.0,
                        cutOutSize: 300,
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
    });

    if (status.isGranted) {
      _initializeCamera();
    }
  }

  void _initializeCamera() {
    availableCameras().then((cameras) {
      print('Available Cameras: $cameras');

      final rearCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      print('Selected Camera: $rearCamera');

      _cameraController = CameraController(rearCamera, ResolutionPreset.max);
      _cameraController!.initialize().then((value) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isCameraInitialized = true;
        });
      });
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });

    _qrViewController!.scannedDataStream.listen((scanData) async {
      if (!await launcher.launchUrl(
        scanData.code!,
        const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
      )) {
        throw Exception('Could not launch ${scanData.code!}');
      }
    });

    // _qrViewController!.toggleFlash();
    _setCameraFocusMode(FocusMode.auto);
    _cameraController!.startImageStream((cameraImage) {
      if (_qrViewController != null) {
        final qrCode = _decodeQRCode(cameraImage);
        if (qrCode != null) {
          _qrViewController!.pauseCamera();
          // Handle the scanned QR code data here
          print(qrCode);
        }
      }
    });
  }

  Future<void> _setCameraFocusMode(FocusMode focusMode) async {
    final currentFocusMode = _cameraController!.value.focusMode;
    if (currentFocusMode == focusMode) {
      return;
    }

    await _cameraController!.setFocusMode(focusMode);
  }

  String? _decodeQRCode(CameraImage cameraImage) {
    // Perform QR code decoding here using cameraImage
    // Return the decoded QR code or null if no QR code is found
    // Replace this with your own QR code decoding implementation

    return null;
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kBlack,
      centerTitle: true,
      title: const Text("QR Scanner"),
      actions: const [
        Text(""),
      ],
      leading: const Text(""),
    );
  }
}
