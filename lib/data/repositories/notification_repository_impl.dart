
import '../../domain/entities/notification.dart' as app_notification;
import '../../domain/entities/user.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDatasource datasource;

  NotificationRepositoryImpl(this.datasource);

  @override
  Future<void> sendPushNotification(User user, app_notification.Notification notification) {
    return datasource.sendPushNotification(user, notification);
  }

  @override
  Future<void> sendEmailNotification(User user, app_notification.Notification notification) {
    return datasource.sendEmailNotification(user, notification);
  }
}
