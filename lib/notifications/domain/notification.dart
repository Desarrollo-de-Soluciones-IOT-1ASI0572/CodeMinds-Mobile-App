class Notification {
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

  Notification({
    this.id = 0,
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
}
