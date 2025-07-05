import '../../domain/trip.dart';

class TripDTO {
  final int id;
  final int vehicleId;
  final String origin;
  final String destination;
  final DateTime startTime;
  final DateTime endTime;

  TripDTO({
    required this.id,
    required this.vehicleId,
    required this.origin,
    required this.destination,
    required this.startTime,
    required this.endTime,
  });

  factory TripDTO.fromJson(Map<String, dynamic> json) {
    return TripDTO(
      id: json['id'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

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

  Trip toTrip() {
    return Trip(
      id: id,
      vehicleId: vehicleId,
      origin: origin,
      destination: destination,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

class TripUiDto {
  final int id;
  final String title; // Ej: "March 24 Trip"
  final String shortDate; // Ej: "March, 24"
  final String origin;
  final String destination;

  TripUiDto({
    required this.id,
    required this.title,
    required this.shortDate,
    required this.origin,
    required this.destination,
  });

  factory TripUiDto.fromTrip(Trip trip) {
    final date = trip.startTime;
    final shortDate = "${_monthName(date.month)}, ${date.day}";
    final title = "$shortDate Trip";
    return TripUiDto(
      id: trip.id,
      title: title,
      shortDate: shortDate,
      origin: trip.origin,
      destination: trip.destination,
    );
  }

  static String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}
