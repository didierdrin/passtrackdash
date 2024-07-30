import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({required this.id, required this.name, required this.email, required this.role});
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User currentUser;
  List<User> systemUsers = [];

  @override
  void initState() {
    super.initState();
    // Mock data
    currentUser = User(id: '1', name: 'John Doe', email: 'john@example.com', role: 'Admin');
    systemUsers = [
      User(id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'Staff'),
      User(id: '3', name: 'Bob Johnson', email: 'bob@example.com', role: 'Client'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(),
            const SizedBox(height: 20),
            _buildPasswordChangeOption(),
            const SizedBox(height: 20),
            _buildSystemUsersList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(currentUser.name),
              subtitle: Text(currentUser.email),
            ),
            Text('Role: ${currentUser.role}'),
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
            const Text('System Users', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration:  InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                obscureText: true,
                decoration:  InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement password change logic here
                Navigator.of(context).pop();
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  void _showUserDialog({User? user}) {
    final isEditing = user != null;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    String role = user?.role ?? 'Staff';

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
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
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
              onPressed: () {
                // Implement create/update logic here
                final newUser = User(
                  id: user?.id ?? DateTime.now().toString(),
                  name: nameController.text,
                  email: emailController.text,
                  role: role,
                );
                setState(() {
                  if (isEditing) {
                    systemUsers[systemUsers.indexWhere((u) => u.id == user.id)] = newUser;
                  } else {
                    systemUsers.add(newUser);
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}