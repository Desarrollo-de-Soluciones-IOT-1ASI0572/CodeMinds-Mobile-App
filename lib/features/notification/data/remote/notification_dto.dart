import 'package:codeminds_mobile_application/features/notification/domain/notification.dart';

class NotificationDTO {
  final int id;
  final String message;
  final String status;

  NotificationDTO({
    required this.id,
    required this.message,
    required this.status,
  });

  // Método para crear NotificationDTO desde un JSON, útil para recibir datos de la API
  factory NotificationDTO.fromJson(Map<String, dynamic> json) {
    return NotificationDTO(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // Método para convertir NotificationDTO a Map
  Map<String, dynamic> toJson() {
    return {
      'notification': {'message': message, 'status': status},
    };
  }

  Notification toNotification() {
    return Notification(id: id, message: message, status: status);
  }
}
