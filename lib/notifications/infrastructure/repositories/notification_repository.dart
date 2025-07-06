import '../../application/services/notification_service.dart';
import '../../domain/entities/notification.dart';
import '../remote/notification_model.dart';

class NotificationRepository {
  final NotificationService notificationService;

  NotificationRepository({required this.notificationService});

  Future<List<Notification>> getNotificationsByUserId(int id) async {
    List<NotificationModel> localDto = await notificationService
        .getNotificationsByUserId(id);

    return localDto.map((localDto) => localDto.toNotification()).toList();
  }
}
