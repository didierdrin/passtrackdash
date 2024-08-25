import 'package:flutter/material.dart';
import 'package:passtrackdash/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Post {
  final String id;
  final String title;
  final String subtitle;
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mcgpalette0[50],
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPostDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: _buildPostList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search notifications...',
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
    );
  }

  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Post> posts = snapshot.data!.docs
            .map((doc) => Post.fromFirestore(doc))
            .where((post) {
          return post.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              post.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _notificationTile(posts[index]);
          },
        );
      },
    );
  }

  Widget _notificationTile(Post post) {
    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(post.title),
        subtitle: Text(post.subtitle),
        trailing: Text(DateFormat('yyyy-MM-dd HH:mm').format(post.timestamp.toDate())),
        onTap: () => _showPostDetails(post),
      ),
    );
  }

  void _showPostDialog({Post? post}) {
    final TextEditingController titleController = TextEditingController(text: post?.title);
    final TextEditingController subtitleController = TextEditingController(text: post?.subtitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(post == null ? 'Create Notification' : 'Edit Notification'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Subtitle')),
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
                  'title': titleController.text,
                  'subtitle': subtitleController.text,
                  'timestamp': Timestamp.now(),
                };

                if (post == null) {
                  _firestore.collection('posts').add(data);
                } else {
                  _firestore.collection('posts').doc(post.id).update(data);
                }

                Navigator.of(context).pop();
              },
              child: Text(post == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showPostDetails(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(post.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.subtitle),
              const SizedBox(height: 10),
              Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(post.timestamp.toDate())}'),
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
                _showPostDialog(post: post);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('posts').doc(post.id).delete();
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