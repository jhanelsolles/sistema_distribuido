
import '../entities/notification.dart';
import '../entities/user.dart';

abstract class NotificationRepository {
  Future<void> sendPushNotification(User user, Notification notification);
  Future<void> sendEmailNotification(User user, Notification notification);
}
