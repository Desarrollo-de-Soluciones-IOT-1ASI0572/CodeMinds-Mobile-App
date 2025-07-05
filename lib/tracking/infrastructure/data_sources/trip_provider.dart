import 'package:flutter/material.dart';

class TripState {
  final int tripId;
  final int driverId;
  bool isStarted;
  DateTime? startTime;
  DateTime? endTime;

  final String originAddress;     // 👈 NUEVO
  final String destinationAddress; // 👈 NUEVO

  TripState({
    required this.tripId,
    required this.driverId,
    this.isStarted = false,
    this.startTime,
    this.endTime,
    required this.originAddress,      // 👈 NUEVO
    required this.destinationAddress, // 👈 NUEVO
  });
}


class TripProvider with ChangeNotifier {
  final Map<int, TripState> _trips = {}; // Key: driverId

  // Getters
  TripState? getCurrentTrip(int driverId) => _trips[driverId];

  bool isTripStarted(int driverId) => _trips[driverId]?.isStarted ?? false;
  bool hasActiveTrip(int driverId) => _trips.containsKey(driverId);
  int? getCurrentTripId(int driverId) => _trips[driverId]?.tripId;

  // Métodos para modificar el estado
  void createNewTrip(int tripId, int driverId, String originAddress, String destinationAddress) {
    _trips[driverId] = TripState(
      tripId: tripId,
      driverId: driverId,
      isStarted: false,
      startTime: null,
      endTime: null,
      originAddress: originAddress,
      destinationAddress: destinationAddress,
    );
    notifyListeners();
  }


  void startTrip(int driverId) {
    final trip = _trips[driverId];
    if (trip == null) return;

    trip.isStarted = true;
    trip.startTime = DateTime.now();
    notifyListeners();
  }

  void endTrip(int driverId) {
    final trip = _trips[driverId];
    if (trip == null) return;

    trip.isStarted = false;
    trip.endTime = DateTime.now();
    notifyListeners();
  }

  void resetTrip(int driverId) {
    _trips.remove(driverId);
    notifyListeners();
  }

  bool isTripForDriver(int driverId, int targetDriverId) {
    return _trips[driverId]?.driverId == targetDriverId;
  }
}