import 'package:codeminds_mobile_application/features/notification/data/remote/notification_dto.dart';
import 'package:codeminds_mobile_application/features/notification/data/remote/notification_service.dart';
import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';

class NotificationRepository {
  final NotificationService notificationService;

  NotificationRepository({required this.notificationService});

  Future<List<Notification>> getNotificationsByUserId(int id) async {
    List<NotificationDTO> localDto = await notificationService
        .getNotificationsByUserId(id);

    return localDto.map((localDto) => localDto.toNotification()).toList();
  }
}
