import 'package:flutter/material.dart';

class TripProvider with ChangeNotifier {
  int? _currentTripId;
  bool _tripStarted = false;
  int? _currentDriverId;

  // Getters
  int? get currentTripId => _currentTripId;
  bool get tripStarted => _tripStarted;
  bool get hasActiveTrip => _currentTripId != null;
  int? get currentDriverId => _currentDriverId;

  // Métodos para modificar el estado
  void createNewTrip(int tripId, int driverId) {
    _currentTripId = tripId;
    _currentDriverId = driverId;
    _tripStarted = false;
    notifyListeners();
  }

  void startCurrentTrip() {
    if (_currentTripId == null) return;
    _tripStarted = true;
    notifyListeners();
  }

  void endCurrentTrip() {
    _currentTripId = null;
    _currentDriverId = null;
    _tripStarted = false;
    notifyListeners();
  }

  void resetTrip() {
    _currentTripId = null;
    _currentDriverId = null;
    _tripStarted = false;
    notifyListeners();
  }

  bool isTripForDriver(int driverId) {
    return _currentDriverId == driverId;
  }
}