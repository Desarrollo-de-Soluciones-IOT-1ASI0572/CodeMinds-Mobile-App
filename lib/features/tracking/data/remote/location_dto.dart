class LocationDTO {
  final int id;
  final int vehicleId;
  final double latitude;
  final double longitude;
  final double speed;

  LocationDTO({
    required this.id,
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.speed,
  });

  factory LocationDTO.fromJson(Map<String, dynamic> json) {
    return LocationDTO(
      id: json['id'],
      vehicleId: json['vehicleId'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      speed: json['speed'].toDouble(),
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
