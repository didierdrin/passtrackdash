import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRcodePage extends StatefulWidget {
  const QRcodePage({super.key});

  @override
  State<QRcodePage> createState() => _QRcodePageState();
}

class _QRcodePageState extends State<QRcodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = '';
  bool isValid = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: _buildResult(),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code!;
        // Implement your ticket verification logic here
        isValid = _verifyTicket(result);
      });
    });
  }

  bool _verifyTicket(String qrData) {
    // Implement your ticket verification logic here
    // For this example, we'll just check if the QR code starts with 'VALID_TICKET_'
    return qrData.startsWith('VALID_TICKET_');
  }

  Widget _buildResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isValid ? 'Valid Ticket' : 'Invalid Ticket',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isValid ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Scanned Result: $result',
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }
}