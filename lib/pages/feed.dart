import 'package:flutter/material.dart';
import 'package:passtrackdash/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path; 

class Post {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imgUrl;
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imgUrl,
    required this.timestamp,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      imgUrl: data['imgUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mcgpalette0[50],
        title: const Text("Timeline"),
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
        hintText: 'Search posts...',
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
            return _postCard(posts[index]);
          },
        );
      },
    );
  }

  Widget _postCard(Post post) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: SizedBox(
          height: 40,
          width: 40,
          child: Image.network(post.imgUrl, fit: BoxFit.cover),
        ),
        title: Text(post.title),
        subtitle: Text(post.subtitle),
        onTap: () => _showPostDetails(post),
      ),
    );
  }

  void _showPostDialog({Post? post}) {
  final TextEditingController titleController = TextEditingController(text: post?.title);
  final TextEditingController subtitleController = TextEditingController(text: post?.subtitle);
  final TextEditingController descriptionController = TextEditingController(text: post?.description);
  File? _image;
  String? _imageUrl = post?.imgUrl;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(post == null ? 'Create Post' : 'Edit Post'),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Subtitle')),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  const SizedBox(height: 10),
                  _image != null
                      ? Image.file(_image!, height: 100)
                      : _imageUrl != null
                          ? Image.network(_imageUrl, height: 100)
                          : const SizedBox(),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _image = File(image.path);
                        });
                      }
                    },
                    child: const Text('Pick Image'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String? imageUrl = _imageUrl;
                  if (_image != null) {
                    final fileName = path.basename(_image!.path);
                    final ref = FirebaseStorage.instance.ref().child('post_images/$fileName');
                    await ref.putFile(_image!);
                    imageUrl = await ref.getDownloadURL();
                  }

                  final data = {
                    'title': titleController.text,
                    'subtitle': subtitleController.text,
                    'description': descriptionController.text,
                    'imgUrl': imageUrl,
                    'timestamp': Timestamp.now(),
                  };

                  if (post == null) {
                    await _firestore.collection('posts').add(data);
                  } else {
                    await _firestore.collection('posts').doc(post.id).update(data);
                  }

                  Navigator.of(context).pop();
                },
                child: Text(post == null ? 'Create' : 'Update'),
              ),
            ],
          );
        },
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
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(post.imgUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text(post.subtitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(post.description),
                const SizedBox(height: 10),
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(post.timestamp.toDate())}'),
              ],
            ),
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