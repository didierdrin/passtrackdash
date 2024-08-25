import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SummaryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalSales = 0;
  int ticketsSoldToday = 0;
  Map<String, double> salesByRoute = {};
  bool isLoading = false;

  Future<void> fetchData() async {
    isLoading = true;
    notifyListeners();

    totalSales = 0;
    ticketsSoldToday = 0;
    salesByRoute = {};

    try {
      QuerySnapshot purchasesSnapshot = await _firestore.collection('totalpurchases').get();

      print('Found ${purchasesSnapshot.docs.length} purchases');

      if (purchasesSnapshot.docs.isEmpty) {
        print('No purchases found in the totalpurchases collection');
        isLoading = false;
        notifyListeners();
        return;
      }

      for (QueryDocumentSnapshot purchaseDoc in purchasesSnapshot.docs) {
        Map<String, dynamic> purchaseData = purchaseDoc.data() as Map<String, dynamic>;

        double price = (purchaseData['price'] as num).toDouble();
        totalSales += price;

        String routeFrom = purchaseData['route_from'];
        String routeTo = purchaseData['route_to'];
        String route = '$routeFrom > $routeTo';

        salesByRoute[route] = (salesByRoute[route] ?? 0) + price;

        Timestamp purchaseDate = purchaseData['purchaseDate'];
        if (isToday(purchaseDate)) {
          ticketsSoldToday++;
        }
      }

      print('Total Sales: $totalSales');
      print('Tickets Sold Today: $ticketsSoldToday');
      print('Sales by Route: $salesByRoute');
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isToday(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}