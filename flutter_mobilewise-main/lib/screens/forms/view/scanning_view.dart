import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../../utils/common_constants.dart' as constants;

class ScanningView extends StatefulWidget {
  ScanningView(this.label, {super.key});

  String? label;

  @override
  State<StatefulWidget> createState() => _ScanningViewExampleState();
}

class _ScanningViewExampleState extends State<ScanningView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scannedText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop('');
        return true;
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildQrView(context),
            Positioned(
              top: MediaQuery
                  .of(context)
                  .size
                  .height / 3.5,
              child: Container(
                child: result != null
                    ? Text(
                  '${widget.label} : ${result!.code}',
                  style: constants.buttonTextStyle,
                )
                    : Text(
                  '${widget.label} : ',
                  style: constants.buttonTextStyle,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                height: 40,
                width: 40,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('');
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              child: Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.all(8),
                child: GestureDetector(
                    onTap: () async {
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    child: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null && snapshot.data == true) {
                          return Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.flash_on));
                        } else {
                          return Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.flash_off));
                        }
                      },
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery
        .of(context)
        .size
        .width < 350 ||
        MediaQuery
            .of(context)
            .size
            .height < 350)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    if (Platform.isAndroid) {
      await controller.resumeCamera();
    }
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      if (result != null && scannedText != result!.code) {
        _delayAndNavigateToPrevoiusScreen();
      }
      await controller.pauseCamera();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _delayAndNavigateToPrevoiusScreen() {
    try {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pop(result!.code);
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
