import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/auth.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;

  AppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.role});
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? currentUser;
  List<AppUser> systemUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSystemUsers();
  }

  Future<void> _loadUserData() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('userinfo')
          .doc('default_doc_id')
          .get();

      if (doc.exists) {
        setState(() {
          currentUser = AppUser(
            id: firebaseUser.uid,
            name: doc['name'] ?? '',
            email: doc['email'] ?? '',
            role: doc['role'] ?? 'Client',
          );
        });
      }
    }
  }

  Future<void> _loadSystemUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    setState(() {
      systemUsers = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return AppUser(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'Client',
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _auth.currentUser != null
                ? _buildUserProfile()
                : _buildSignInRegister(),
            const SizedBox(height: 20),
            if (_auth.currentUser != null) ...[
              _buildPasswordChangeOption(),
              const SizedBox(height: 20),
              _buildSystemUsersList(),
            ],
          ],
        ),
      ),
      floatingActionButton: _auth.currentUser != null
          ? FloatingActionButton(
              onPressed: () => _showUserDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildUserProfile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Information',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(currentUser?.name ?? 'N/A'),
              subtitle: Text(currentUser?.email ?? 'N/A'),
            ),
            Text('Role: ${currentUser?.role ?? 'N/A'}'),
            ElevatedButton(
              onPressed: _showAddDetailsDialog,
              child: const Text('Update Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInRegister() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showSignInDialog,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _showRegisterDialog,
              child: const Text('Create an Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeOption() {
    return ElevatedButton(
      onPressed: () => _showChangePasswordDialog(),
      child: const Text('Change Password'),
    );
  }

  Widget _buildSystemUsersList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('System Users',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: systemUsers.length,
              itemBuilder: (context, index) {
                final user = systemUsers[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Text(user.role),
                  onTap: () => _showUserDialog(user: user),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                onChanged: (value) => currentPassword = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                onChanged: (value) => newPassword = value,
              ),
              TextField(
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password'),
                onChanged: (value) => confirmPassword = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPassword == confirmPassword) {
                  try {
                    User? user = _auth.currentUser;
                    if (user != null) {
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: currentPassword,
                      );
                      await user.reauthenticateWithCredential(credential);
                      await user.updatePassword(newPassword);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password updated successfully')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                }
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  void _showAddDetailsDialog() async {
    String? name = currentUser?.name;
    String? email = currentUser?.email;
    String role = currentUser?.role ?? 'Client';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
                controller: TextEditingController(text: email),
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: ['Admin', 'Staff', 'Client'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    role = newValue;
                  }
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              User? user = _auth.currentUser;
              if (user != null) {
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('userinfo')
                    .doc('default_doc_id')
                    .set({
                  'name': name,
                  'email': email,
                  'role': role,
                });
                Navigator.of(context).pop();
                _loadUserData();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showUserDialog({AppUser? user}) {
    final isEditing = user != null;
    String name = user?.name ?? '';
    String email = user?.email ?? '';
    String role = user?.role ?? 'Client';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit User' : 'Add User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) => name = value,
                  controller: TextEditingController(text: name),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) => email = value,
                  controller: TextEditingController(text: email),
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  items: ['Admin', 'Staff', 'Client'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      role = newValue;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isEditing) {
                  await _firestore.collection('users').doc(user!.id).update({
                    'name': name,
                    'email': email,
                    'role': role,
                  });
                } else {
                  await _firestore.collection('users').add({
                    'name': name,
                    'email': email,
                    'role': role,
                  });
                }
                Navigator.of(context).pop();
                _loadSystemUsers();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showSignInDialog() {
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) => password = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _auth.signInWithEmailAndPassword(
                      email: email, password: password);
                  Navigator.of(context).pop();
                  _loadUserData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  void _showRegisterDialog() {
    String name = '';
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create an Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (value) => password = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await _firestore
                      .collection('users')
                      .doc(userCredential.user!.uid)
                      .collection('userinfo')
                      .doc('default_doc_id')
                      .set({
                    'name': name,
                    'email': email,
                    'role': 'Client',
                  });
                  Navigator.of(context).pop();
                  _loadUserData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }
}
