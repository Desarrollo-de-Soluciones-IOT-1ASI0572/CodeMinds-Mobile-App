import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_dto.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_service.dart';
import 'package:codeminds_mobile_application/features/tracking/domain/trip.dart';

class TripRepository {
  final TripService tripService;

  TripRepository({required this.tripService});

  Future<List<Trip>> getAllTrips() async {
    List<TripDTO> tripDtoList = await tripService.getAllTrips();
    return tripDtoList.map((dto) => dto.toTrip()).toList();
  }
}
