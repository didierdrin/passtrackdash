import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Ticket {
  final String id;
  final String busName;
  final GeoPoint from;
  final GeoPoint to;
  final double price;
  final String routeFrom;
  final String routeTo;
  final Timestamp timeCreated;

  Ticket({
    required this.id,
    required this.busName,
    required this.from,
    required this.to,
    required this.price,
    required this.routeFrom,
    required this.routeTo,
    required this.timeCreated,
  });

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      busName: data['bus_name'] ?? '',
      from: data['from'] ?? const GeoPoint(0, 0),
      to: data['to'] ?? const GeoPoint(0, 0),
      price: (data['price'] ?? 0).toDouble(),
      routeFrom: data['route_from'] ?? '',
      routeTo: data['route_to'] ?? '',
      timeCreated: data['time_created'] ?? Timestamp.now(),
    );
  }
}

class TicketManagementPage extends StatefulWidget {
  const TicketManagementPage({super.key});

  @override
  State<TicketManagementPage> createState() => _TicketManagementPageState();
}

class _TicketManagementPageState extends State<TicketManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: _buildSearchBar()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showTicketDialog(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildTicketList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tickets...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildTicketList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Ticket> tickets = snapshot.data!.docs
            .map((doc) => Ticket.fromFirestore(doc))
            .where((ticket) {
          return ticket.busName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              ticket.routeFrom.toLowerCase().contains(searchQuery.toLowerCase()) ||
              ticket.routeTo.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return _ticketCard(tickets[index]);
          },
        );
      },
    );
  }

  Widget _ticketCard(Ticket ticket) {
    return InkWell(
      onTap: () {
        _showTicketDetails(ticket);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      ticket.busName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _routeInfo("From", ticket.routeFrom, ticket.timeCreated.toDate().toString()),
                    const SizedBox(height: 10),
                    _routeInfo("To", ticket.routeTo, ticket.timeCreated.toDate().toString()),
                  ],
                ),
                const SizedBox(width: 5),
                const DottedLine(
                  direction: Axis.vertical,
                  lineLength: double.infinity,
                  lineThickness: 1.0,
                  dashLength: 3.0,
                  dashColor: Colors.grey,
                ),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text("${ticket.timeCreated.toDate().hour}:${ticket.timeCreated.toDate().minute}"),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(90, 10),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        _showTicketDetails(ticket);
                      },
                      child: const Text(
                        "View Details",
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Price: ",
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            TextSpan(
                              text: "RWF${ticket.price.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeInfo(String label, String location, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: label == "From" ? Colors.green[200] : Colors.grey,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            label == "From" ? Icons.navigation_outlined : Icons.location_pin,
            color: label == "From" ? Colors.green : Colors.black,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              location,
              style: const TextStyle(color: Colors.blue),
            ),
            SizedBox(
              width: 80,
              child: Text(
                date,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTicketDialog({Ticket? ticket}) {
    final TextEditingController busNameController = TextEditingController(text: ticket?.busName);
    final TextEditingController routeFromController = TextEditingController(text: ticket?.routeFrom);
    final TextEditingController routeToController = TextEditingController(text: ticket?.routeTo);
    final TextEditingController priceController = TextEditingController(text: ticket?.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(ticket == null ? 'Create Ticket' : 'Edit Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: busNameController, decoration: const InputDecoration(labelText: 'Bus Name')),
                TextField(controller: routeFromController, decoration: const InputDecoration(labelText: 'From')),
                TextField(controller: routeToController, decoration: const InputDecoration(labelText: 'To')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final data = {
                  'bus_name': busNameController.text,
                  'route_from': routeFromController.text,
                  'route_to': routeToController.text,
                  'price': double.parse(priceController.text),
                  'from': const GeoPoint(0, 0), // You need to implement a way to input GeoPoint
                  'to': const GeoPoint(0, 0), // You need to implement a way to input GeoPoint
                  'time_created': Timestamp.now(),
                };

                if (ticket == null) {
                  _firestore.collection('tickets').add(data);
                } else {
                  _firestore.collection('tickets').doc(ticket.id).update(data);
                }

                Navigator.of(context).pop();
              },
              child: Text(ticket == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showTicketDetails(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ticket Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Bus Name: ${ticket.busName}'),
              Text('From: ${ticket.routeFrom}'),
              Text('To: ${ticket.routeTo}'),
              Text('Price: RWF${ticket.price.toStringAsFixed(2)}'),
              Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(ticket.timeCreated.toDate())}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showTicketDialog(ticket: ticket);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('tickets').doc(ticket.id).delete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class DottedLine extends StatelessWidget {
  final double lineLength;
  final double lineThickness;
  final double dashLength;
  final Color dashColor;
  final Axis direction;

  const DottedLine({
    Key? key,
    this.lineLength = 100,
    this.lineThickness = 1.0,
    this.dashLength = 5.0,
    this.dashColor = Colors.black,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(direction == Axis.horizontal ? lineLength : lineThickness,
          direction == Axis.vertical ? lineLength : lineThickness),
      painter: _DottedLinePainter(
        dashLength: dashLength,
        dashColor: dashColor,
        direction: direction,
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final double dashLength;
  final Color dashColor;
  final Axis direction;

  _DottedLinePainter({
    required this.dashLength,
    required this.dashColor,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dashColor
      ..strokeWidth = 1;

    if (direction == Axis.horizontal) {
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(Offset(startX, 0), Offset(startX + dashLength, 0), paint);
        startX += dashLength * 2;
      }
    } else {
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(Offset(0, startY), Offset(0, startY + dashLength), paint);
        startY += dashLength * 2;
      }
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) => false;
}