import 'package:flutter/material.dart';

class Ticket {
  final String id;
  final String name;
  final String route;
  final String busNumber;
  final DateTime date;
  final double price;
  final String passengerName;
  final String seatNumber;

  Ticket({
    required this.id,
    required this.name,
    required this.route,
    required this.busNumber,
    required this.date,
    required this.price,
    required this.passengerName,
    required this.seatNumber,
  });
}

class TicketManagementPage extends StatefulWidget {
  const TicketManagementPage({super.key});

  @override
  State<TicketManagementPage> createState() => _TicketManagementPageState();
}

class _TicketManagementPageState extends State<TicketManagementPage> {
  List<Ticket> tickets = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Mock data
    tickets = [
      Ticket(
        id: '001',
        name: 'Express Route A',
        route: 'City A to City B',
        busNumber: 'KAA 123B',
        date: DateTime.now(),
        price: 1500,
        passengerName: 'John Doe',
        seatNumber: 'A1',
      ),
      // Add more mock tickets here
    ];
  }

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
    final filteredTickets = tickets.where((ticket) {
      return ticket.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          ticket.route.toLowerCase().contains(searchQuery.toLowerCase()) ||
          ticket.busNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(ticket.name),
            subtitle: Text('${ticket.route} - ${ticket.busNumber}'),
            trailing: Text('RWF${ticket.price.toStringAsFixed(2)}'),
            onTap: () => _showTicketDetails(ticket),
          ),
        );
      },
    );
  }

  void _showTicketDialog({Ticket? ticket}) {
    // Show dialog for creating or editing a ticket
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(ticket == null ? 'Create Ticket' : 'Edit Ticket'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: InputDecoration(labelText: 'Name')),
                TextField(decoration: InputDecoration(labelText: 'Route')),
                TextField(decoration: InputDecoration(labelText: 'Bus Number')),
                TextField(decoration: InputDecoration(labelText: 'Price')),
                TextField(
                    decoration: InputDecoration(labelText: 'Passenger Name')),
                TextField(
                    decoration: InputDecoration(labelText: 'Seat Number')),
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
                // Implement create/update logic here
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
              Text('ID: ${ticket.id}'),
              Text('Name: ${ticket.name}'),
              Text('Route: ${ticket.route}'),
              Text('Bus Number: ${ticket.busNumber}'),
              Text('Date: ${ticket.date.toString()}'),
              Text('Price: \$${ticket.price.toStringAsFixed(2)}'),
              Text('Passenger: ${ticket.passengerName}'),
              Text('Seat: ${ticket.seatNumber}'),
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
                // Implement delete logic here
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
