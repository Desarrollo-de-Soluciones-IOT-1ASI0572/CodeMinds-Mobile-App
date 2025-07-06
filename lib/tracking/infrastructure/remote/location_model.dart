class LocationModel {
  final int id;
  final int vehicleId;
  final double latitude;
  final double longitude;
  final double speed;

  LocationModel({
    required this.id,
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.speed,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
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
