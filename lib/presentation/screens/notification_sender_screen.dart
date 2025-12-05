import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications
import 'package:google_fonts/google_fonts.dart';
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
  
  // Simulation vars
  Timer? _simulationTimer;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // In a real app, you would fetch this user list from your backend
  final List<User> _users = [
    User(id: '1', name: 'Alice', email: 'alice@example.com', fcmToken: 'REPLACE_WITH_ALICE_FCM_TOKEN'),
    User(id: '2', name: 'Bob', email: 'bob@example.com', fcmToken: 'REPLACE_WITH_BOB_FCM_TOKEN'),
  ];

  User? _selectedUser;
  String _statusMessage = "Waiting for action...";
  bool _isLoading = false;

  void _toggleSimulation() {
    if (_simulationTimer != null) {
      _simulationTimer!.cancel();
      setState(() {
        _simulationTimer = null;
        _statusMessage = "Simulation stopped";
      });
    } else {
      setState(() {
        _statusMessage = "Simulation started (every 10s)";
      });
      // Trigger immediately
      _showSimulatedNotification();
      _simulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _showSimulatedNotification();
      });
    }
  }

  Future<void> _showSimulatedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'high_importance_channel', // Must match the channel ID in main.dart
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotifications.show(
        DateTime.now().millisecond, // Unique ID
        'Nuevo Mensaje',
        'Hola, ¿cómo estás? Tienes un mensaje pendiente.',
        platformChannelSpecifics,
        payload: 'item x');
        
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mensaje enviado"), duration: Duration(seconds: 1),));
    }
  }

  @override
  void initState() {
    super.initState();
    final notificationRepository = NotificationRepositoryImpl(NotificationDatasourceImpl(http.Client()));
    _sendNotification = SendNotification(notificationRepository);
    _fetchFCMToken();
  }

  Future<void> _fetchFCMToken() async {
    setState(() => _statusMessage = "Requesting permission...");

    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        setState(() => _statusMessage = "Fetching token...");
        
        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          debugPrint("FCM Token: $fcmToken");
          setState(() {
            // Remove existing 'me' user if present to avoid duplicates on retry
            _users.removeWhere((u) => u.id == 'me');
            _users.insert(0, User(id: 'me', name: 'My Device (Self)', email: 'me@test.com', fcmToken: fcmToken));
            _selectedUser = _users.first;
            _statusMessage = "Ready";
          });
        } else {
           setState(() => _statusMessage = "Token is null");
        }
      } else {
         setState(() => _statusMessage = "Permission declined");
      }
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
      setState(() => _statusMessage = "Error: $e");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (_selectedUser == null) {
      _showSnackBar('Please select a user.', isError: true);
      return;
    }

    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      _showSnackBar('Please fill in both title and body.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final notification = app_notification.Notification(
      title: _titleController.text,
      body: _bodyController.text,
    );

    try {
      await _sendNotification.execute(_selectedUser!, notification);
      if (!mounted) return;
      _showSnackBar('Notification sent to ${_selectedUser!.name}', isError: false);
      _titleController.clear();
      _bodyController.clear();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Error sending notification: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _copyToken() {
    if (_selectedUser?.fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _selectedUser!.fcmToken));
      _showSnackBar('Token copied to clipboard!');
    }
  }

  // Add these imports at the top if not present (I will add them in the full file content if I could, but here I am replacing the class content mostly)
  // But wait, I need to add imports. I'll use a larger block or just assume imports are there? 
  // The user wants it FAST. I will replace the whole file to be safe and clean.
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Firebase Messenger', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
           IconButton(
            icon: Icon(_simulationTimer != null ? Icons.stop_circle_outlined : Icons.play_circle_outline),
            onPressed: _toggleSimulation,
            tooltip: "Simular Notificaciones (10s)",
            color: _simulationTimer != null ? Colors.red : Colors.green,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Simulation Banner
            if (_simulationTimer != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Simulando: Notificación cada 10s...", style: textTheme.bodyMedium?.copyWith(color: Colors.green[800]))),
                  ],
                ),
              ),

            // Status Card
            _buildStatusCard(colorScheme, textTheme),
            const SizedBox(height: 24),

            // Token Card
            if (_selectedUser != null && _selectedUser!.id == 'me')
              _buildTokenCard(colorScheme, textTheme),
            
            const SizedBox(height: 24),

            // Form
            Text("Compose Message", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
            const SizedBox(height: 16),
            
            _buildUserDropdown(colorScheme, textTheme),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _bodyController,
              label: 'Body',
              icon: Icons.message,
              maxLines: 4,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 32),

            // Send Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _onSend,
                icon: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Icon(Icons.send_rounded),
                label: Text(_isLoading ? "Sending..." : "Send Notification", style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 4,
                  shadowColor: colorScheme.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondaryContainer),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Status: $_statusMessage",
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFCMToken,
            tooltip: "Retry Connection",
            color: colorScheme.primary,
          )
        ],
      ),
    );
  }

  Widget _buildTokenCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("My Device Token", style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                InkWell(
                  onTap: _copyToken,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text("Copy", style: textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                _selectedUser!.fcmToken,
                style: GoogleFonts.firaCode(fontSize: 11, color: colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDropdown(ColorScheme colorScheme, TextTheme textTheme) {
    return DropdownButtonFormField<User>(
      value: _selectedUser,
      items: _users.map((user) {
        return DropdownMenuItem<User>(
          value: user,
          child: Text(user.name, style: textTheme.bodyLarge),
        );
      }).toList(),
      onChanged: (user) => setState(() => _selectedUser = user),
      decoration: InputDecoration(
        labelText: 'Select User',
        labelStyle: textTheme.bodyMedium,
        prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      dropdownColor: colorScheme.surfaceContainer,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 60 : 0), // Align icon to top if multiline
          child: Icon(icon, color: colorScheme.primary),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
    );
  }
}
