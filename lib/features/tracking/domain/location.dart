import 'package:codeminds_mobile_application/features/tracking/data/remote/location_dto.dart';

class Location {
  final int id;
  final int vehicleId;
  final double latitude;
  final double longitude;
  final double speed;

  Location({
    required this.id,
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.speed,
  });

  factory Location.fromDTO(LocationDTO dto) {
    return Location(
      id: dto.id,
      vehicleId: dto.vehicleId,
      latitude: dto.latitude,
      longitude: dto.longitude,
      speed: dto.speed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
    };
  }
}
