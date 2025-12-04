
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/notification_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart' as app_notification;
import '../../domain/entities/user.dart';
import '../../domain/usecases/send_notification.dart';

class NotificationSenderScreen extends StatefulWidget {
  const NotificationSenderScreen({super.key});

  @override
  State<NotificationSenderScreen> createState() => _NotificationSenderScreenState();
}

class _NotificationSenderScreenState extends State<NotificationSenderScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  late final SendNotification _sendNotification;

  // In a real app, you would fetch this user list from your backend
  final List<User> _users = [
    User(id: '1', name: 'Alice', email: 'alice@example.com', fcmToken: 'REPLACE_WITH_ALICE_FCM_TOKEN'),
    User(id: '2', name: 'Bob', email: 'bob@example.com', fcmToken: 'REPLACE_WITH_BOB_FCM_TOKEN'),
    User(id: '3', name: 'Charlie', email: 'charlie@example.com', fcmToken: 'REPLACE_WITH_CHARLIE_FCM_TOKEN'),
  ];

  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    final notificationRepository = NotificationRepositoryImpl(NotificationDatasourceImpl(http.Client()));
    _sendNotification = SendNotification(notificationRepository);
    if (_users.isNotEmpty) {
      _selectedUser = _users.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    // Store the ScaffoldMessenger before the async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (_selectedUser == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please select a user.')),
      );
      return;
    }

    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please fill in both title and body.')),
      );
      return;
    }

    final notification = app_notification.Notification(
      title: _titleController.text,
      body: _bodyController.text,
    );

    try {
      await _sendNotification.execute(_selectedUser!, notification);
      // Check if the widget is still in the tree before showing the SnackBar.
      if (!mounted) return; 

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Notification sent to ${_selectedUser!.name}')),
      );
      _titleController.clear();
      _bodyController.clear();
    } catch (error) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error sending notification: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Selection Dropdown
              if (_users.isNotEmpty)
                DropdownButtonFormField<User>(
                  value: _selectedUser,
                  items: _users.map((user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.name),
                    );
                  }).toList(),
                  onChanged: (user) {
                    setState(() {
                      _selectedUser = user;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select User',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                const Center(
                  child: Text('No users available.'),
                ),
              const SizedBox(height: 16),

              // Title Text Field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Body Text Field
              TextField(
                controller: _bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Send Button
              ElevatedButton.icon(
                onPressed: _onSend,
                icon: const Icon(Icons.send),
                label: const Text('Send Notification'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
