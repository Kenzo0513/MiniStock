import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  final Function(String) onDetect;

  const BarcodeScannerScreen({super.key, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código de barras')),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final barcode = barcodeCapture.barcodes.first;
          final value = barcode.rawValue;
          if (value != null) {
            onDetect(value);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
