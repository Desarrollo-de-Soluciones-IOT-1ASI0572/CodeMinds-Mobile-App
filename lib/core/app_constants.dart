class AppConstants {
  static const String baseUrl = 'https://edugo-service-de983aa97099.herokuapp.com/api/v1';

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

  static const String tripsEndpoint = '/vehicle-tracking/trips';

  static const String tripsEndpointComplete = '/vehicle-tracking/trips/completed';

  static const String completedTripsByDriverEndpoint = '/vehicle-tracking/trips/completed/driver';

  static const String singInEndpoint = '/authentication/sign-in';
  static const String singUpEndpoint = '/authentication/sign-up';

}
