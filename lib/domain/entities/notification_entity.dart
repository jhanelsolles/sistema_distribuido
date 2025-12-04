
class NotificationEntity {
  final String target; // Can be an FCM token, an email address, etc.
  final String title;
  final String body;

  NotificationEntity({
    required this.target,
    required this.title,
    required this.body,
  });
}
