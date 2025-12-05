
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

import '../../domain/entities/notification.dart' as app_notification;
import '../../domain/entities/user.dart';

abstract class NotificationDatasource {
  Future<void> sendPushNotification(User user, app_notification.Notification notification);
  Future<void> sendEmailNotification(User user, app_notification.Notification notification);
}

class NotificationDatasourceImpl implements NotificationDatasource {
  final http.Client client;

  // IMPORTANT: In a real app, you would use these endpoints.
  // final String _sendPushEndpoint = "https://your-django-backend.com/send-notification"; 
  // final String _sendEmailEndpoint = "https://your-django-backend.com/send-email";

  NotificationDatasourceImpl(this.client);

  @override
  Future<void> sendPushNotification(User user, app_notification.Notification notification) async {
    // DIRECT FCM IMPLEMENTATION (FOR TESTING ONLY)
    // WARNING: Do not use this in production. Your Server Key should be kept secret on your backend.
    
    // TODO: Replace with your actual Server Key from Firebase Console -> Project Settings -> Cloud Messaging
    const String serverKey = "YOUR_SERVER_KEY_HERE"; 

    if (serverKey == "YOUR_SERVER_KEY_HERE") {
      developer.log("Error: Server Key not set.", name: 'notification.datasource');
      throw Exception('Please set your Firebase Server Key in notification_datasource.dart');
    }

    final endpoint = "https://fcm.googleapis.com/fcm/send";

    try {
      final response = await client.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: json.encode({
          'to': user.fcmToken,
          'notification': {
            'title': notification.title,
            'body': notification.body,
          },
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        developer.log("Push notification sent successfully!", name: 'notification.datasource');
      } else {
        developer.log("Failed to send push notification: ${response.body}", name: 'notification.datasource');
        throw Exception('Failed to send push notification: ${response.statusCode}');
      }
    } catch (e) {
      developer.log("Error sending push notification: $e", name: 'notification.datasource', error: e);
      throw Exception('Failed to send push notification');
    }
  }

  @override
  Future<void> sendEmailNotification(User user, app_notification.Notification notification) async {
    // This simulates calling your Django backend to send an email.
    developer.log("Simulating sending EMAIL to ${user.email}.", name: 'notification.datasource');
    developer.log("Title: ${notification.title}, Body: ${notification.body}", name: 'notification.datasource');
    
    /*
    // Example of a real implementation:
     try {
      final response = await client.post(
        Uri.parse(_sendEmailEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': user.email,
          'subject': notification.title,
          'message': notification.body,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send email notification');
      }
    } catch (e) {
      developer.log("Error sending email notification: $e", name: 'notification.datasource', error: e);
      throw Exception('Failed to send email notification');
    }
    */
  }
}
