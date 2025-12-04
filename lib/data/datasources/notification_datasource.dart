
import 'package:http/http.dart' as http;
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
    // This simulates calling your Django backend to send a push notification.
    // Your backend would then use the Firebase Admin SDK to send the message to the user's fcmToken.
    developer.log("Simulating sending PUSH notification to ${user.name} via Django backend.", name: 'notification.datasource');
    developer.log("Title: ${notification.title}, Body: ${notification.body}", name: 'notification.datasource');

    /*
    // Example of a real implementation:
    try {
      final response = await client.post(
        Uri.parse(_sendPushEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fcm_token': user.fcmToken,
          'title': notification.title,
          'body': notification.body,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send push notification');
      }
    } catch (e) {
      developer.log("Error sending push notification: $e", name: 'notification.datasource', error: e);
      throw Exception('Failed to send push notification');
    }
    */
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
