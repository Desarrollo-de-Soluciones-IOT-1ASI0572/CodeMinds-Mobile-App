import '../../domain/entities/notification.dart';

class NotificationModel {
  final int id;
  final String message;
  final String status;
  final String userType;
  final int userId;
  final String eventType;
  final String description;
  final DateTime timestamp;
  final int? tripId;
  final int? studentId;

  NotificationModel({
    required this.id,
    required this.message,
    required this.status,
    required this.userType,
    required this.userId,
    required this.eventType,
    required this.description,
    required this.timestamp,
    this.tripId,
    this.studentId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      status: json['status'] ?? '',
      userType: json['userType'] ?? '',
      userId: json['userId'] ?? 0,
      eventType: json['eventType'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      tripId: json['tripId'],
      studentId: json['studentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'status': status,
      'userType': userType,
      'userId': userId,
      'eventType': eventType,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'tripId': tripId,
      'studentId': studentId,
    };
  }

  Notification toNotification() {
    return Notification(
      id: id,
      message: message,
      status: status,
      userType: userType,
      userId: userId,
      eventType: eventType,
      description: description,
      timestamp: timestamp,
      tripId: tripId,
      studentId: studentId,
    );
  }
}
