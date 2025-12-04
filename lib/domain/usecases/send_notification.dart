
import '../entities/notification.dart';
import '../entities/user.dart';
import '../repositories/notification_repository.dart';

class SendNotification {
  final NotificationRepository repository;

  SendNotification(this.repository);

  Future<void> execute(User user, Notification notification) async {
    // Here you can add more logic, for example, choosing the channel
    await repository.sendPushNotification(user, notification);
    // await repository.sendEmailNotification(user, notification);
  }
}
