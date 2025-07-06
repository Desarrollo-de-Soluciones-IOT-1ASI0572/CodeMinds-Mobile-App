import '../../domain/entities/notification.dart';
import '../remote/notification_dto.dart';
import '../remote/notification_service.dart';

class NotificationRepository {
  final NotificationService notificationService;

  NotificationRepository({required this.notificationService});

  Future<List<Notification>> getNotificationsByUserId(int id) async {
    List<NotificationDTO> localDto = await notificationService
        .getNotificationsByUserId(id);

    return localDto.map((localDto) => localDto.toNotification()).toList();
  }
}
