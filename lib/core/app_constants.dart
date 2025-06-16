class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  static const String notificationsBase = '/notifications';

  static const String notificationsByUserTypeEndpoint =
      '$notificationsBase/user-type';

  static const String notificationsByUserIdEndpoint =
      '$notificationsBase/user-id';

  static const String notificationsByStudentIdEndpoint =
      '$notificationsBase/student-id';

  static const String notificationsByTripIdEndpoint =
      '$notificationsBase/trip-id';

  static const String notificationsByUserAndTripEndpoint =
      '$notificationsBase/user-id/{userId}/trip-id/{tripId}';
}
