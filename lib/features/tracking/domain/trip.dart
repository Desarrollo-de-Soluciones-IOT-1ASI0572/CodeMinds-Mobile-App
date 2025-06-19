class Trip {
  final int id;
  final int vehicleId;
  final String origin;
  final String destination;
  final DateTime startTime;
  final DateTime endTime;

  Trip({
    required this.id,
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'origin': origin,
      'destination': destination,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }
}
