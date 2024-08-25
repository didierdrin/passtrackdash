import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'dart:async'; // For the timer

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
  bool showResult = false; // To control when to show the result

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
    controller.scannedDataStream.listen((scanData) async {
      String scannedQrData = scanData.code ?? '';

      bool isValidTicket = await _verifyAndDeactivateTicket(scannedQrData);

      // Reset the UI to hide result first
      setState(() {
        showResult = false;
        isValid = false; // Initially set to false
      });

      if (isValidTicket) {
        // Wait for 3 seconds before showing the result
        Timer(const Duration(seconds: 3), () {
          setState(() {
            isValid = true; // Show valid ticket message
            showResult = true; // Now show the result after 3 seconds
            result = scannedQrData; // Set the result
          });
        });
      } else {
        // Immediately show invalid ticket message
        setState(() {
          isValid = false;
          showResult = true;
          result = scannedQrData;
        });
      }
    });
  }

  //Function to verify and deactivate the ticket
  // Future<bool> _verifyAndDeactivateTicket(String scannedQrData) async {
  //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //   try {
  //     // Query the Firestore collection 'notscanned' to find the matching qrData
  //     final QuerySnapshot result = await _firestore
  //         .collection('notscanned')
  //         .where('qrData', isEqualTo: scannedQrData)
  //         .limit(1)
  //         .get();

  //     if (result.docs.isEmpty) {
  //       // No matching ticket found
  //       return false;
  //     }

  //     final DocumentSnapshot ticket = result.docs.first;

  //     if (ticket['status'] == 'used') {
  //       // Ticket has already been used
  //       return false;
  //     } else {
  //       // Ticket is valid, deactivate it by marking the status as 'used'
  //       await _firestore.collection('notscanned').doc(ticket.id).update({
  //         'status': 'used',
  //       });

  //       // Also update the 'users' collection to reflect the change
  //     final QuerySnapshot userTicketResult = await _firestore
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser?.uid)
  //         .collection('tickethistory')
  //         .where('ticketdetails.qrData', isEqualTo: scannedQrData)
  //         .limit(1)
  //         .get();

  //     if (userTicketResult.docs.isNotEmpty) {
  //       final DocumentSnapshot userTicket = userTicketResult.docs.first;
  //       await _firestore
  //           .collection('users')
  //           .doc(FirebaseAuth.instance.currentUser?.uid)
  //           .collection('tickethistory')
  //           .doc(userTicket.id)
  //           .update({
  //         'ticketdetails.status': 'used',
  //       });
  //     }

  //       return true;
  //     }
  //   } catch (e) {
  //     // Handle any errors
  //     print('Error verifying ticket: $e');
  //     return false;
  //   }
  // }

  // Function to verify and deactivate the ticket
Future<bool> _verifyAndDeactivateTicket(String scannedQrData) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    // Query the Firestore collection 'notscanned' to find the matching qrData
    final QuerySnapshot notScannedResult = await _firestore
        .collection('notscanned')
        .where('qrData', isEqualTo: scannedQrData)
        .limit(1)
        .get();

    if (notScannedResult.docs.isEmpty) {
      // No matching ticket found in 'notscanned'
      return false;
    }

    final DocumentSnapshot notScannedTicket = notScannedResult.docs.first;
    final String clientUid = notScannedTicket['client_uid']; // Get the correct client_uid

    if (notScannedTicket['status'] == 'used') {
      // Ticket has already been used
      return false;
    } else {
      // Ticket is valid, deactivate it by marking the status as 'used' in 'notscanned'
      await _firestore.collection('notscanned').doc(notScannedTicket.id).update({
        'status': 'used',
      });

      // Also update the 'users' collection to reflect the change using the correct client_uid
      final QuerySnapshot userTicketResult = await _firestore
          .collection('users')
          .doc(clientUid) // Use the client_uid instead of the currently authenticated user ID
          .collection('tickethistory')
          .where('ticketdetails.qrData', isEqualTo: scannedQrData)
          .limit(1)
          .get();

      if (userTicketResult.docs.isNotEmpty) {
        final DocumentSnapshot userTicket = userTicketResult.docs.first;
        await _firestore
            .collection('users')
            .doc(clientUid) // Ensure we update the correct user's ticket history
            .collection('tickethistory')
            .doc(userTicket.id)
            .update({
          'ticketdetails.status': 'used',
        });
      }

      return true;
    }
  } catch (e) {
    // Handle any errors
    print('Error verifying ticket: $e');
    return false;
  }
}


  

  Widget _buildResult() {
    if (!showResult) {
      // Show a loading spinner while waiting for the delay
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
              isValid
                  ? 'Scanned Result: The ticket is valid & paid \n$result'
                  : 'Scanned Result: The ticket is already checked \n$result',
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
