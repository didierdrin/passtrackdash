import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Import for Firebase
import 'package:passtrackdash/colors.dart'; 
import 'package:intl/intl.dart';


class Promotion {
  final String id;
  final String title;
  final String subtitle;
  final Timestamp timestamp;

  Promotion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize Firebase if not already done
    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mcgpalette0[50],
        title: const Text("Promotions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPromotionDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: _buildSearchBar()),
              ],
            ),
          ),
          Expanded(
            child: _buildPromotionList(),
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
          hintText: 'Search promotions...',
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

  Widget _buildPromotionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('promotions').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Promotion> promotions = snapshot.data!.docs
            .map((doc) => Promotion.fromFirestore(doc))
            .where((promotion) =>
                promotion.title
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                promotion.subtitle
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            return _promotionTile(promotions[index]);
          },
        );
      },
    );
  }

  Widget _promotionTile(Promotion promotion) {
    return InkWell(
      onTap: () => _showPromotionDetails(promotion),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promotion.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(promotion.subtitle),
                const SizedBox(height: 10),
                Text(DateFormat('dd-MM-yyyy')
                    .format(promotion.timestamp.toDate())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPromotionDialog({Promotion? promotion}) {
    final TextEditingController titleController =
        TextEditingController(text: promotion?.title);
    final TextEditingController subtitleController =
        TextEditingController(text: promotion?.subtitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(promotion == null ? 'Create Promotion' : 'Edit Promotion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: subtitleController,
                  decoration: const InputDecoration(labelText: 'Subtitle')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final data = {
                  'title': titleController.text,
                  'subtitle': subtitleController.text,
                  'timestamp': Timestamp.now(),
                };

                if (promotion == null) {
                  _firestore.collection('promotions').add(data);
                } else {
                  _firestore
                      .collection('promotions')
                      .doc(promotion.id)
                      .update(data);
                }

                Navigator.of(context).pop();
              },
              child: Text(promotion == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showPromotionDetails(Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Promotion Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${promotion.title}'),
              Text('Subtitle: ${promotion.subtitle}'),
              Text(
                  'Date: ${DateFormat('dd-MM-yyyy').format(promotion.timestamp.toDate())}'),
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
                _showPromotionDialog(promotion: promotion);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('promotions').doc(promotion.id).delete();
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
