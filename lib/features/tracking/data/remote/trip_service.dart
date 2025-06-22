import 'dart:convert';
import 'dart:io';
import 'package:codeminds_mobile_application/features/tracking/data/remote/location_dto.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_dto.dart';
import 'package:codeminds_mobile_application/features/tracking/domain/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:codeminds_mobile_application/core/app_constants.dart';

class TripService {
  Future<List<TripDTO>> getAllTrips() async {
    String url = '${AppConstants.baseUrl}${AppConstants.tripsEndpoint}';

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((model) => TripDTO.fromJson(model)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteTrip(int tripId) async {
    final url = '${AppConstants.baseUrl}${AppConstants.tripsEndpoint}/$tripId';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<Location>> getTripLocations(int tripId) async {
    final url =
        '${AppConstants.baseUrl}/vehicle-tracking/locations/trip/$tripId';
    debugPrint('🔍 Llamando a: $url');

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);

        return jsonResponse
            .map((model) => Location.fromDTO(LocationDTO.fromJson(model)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentVehicleLocation(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/vehicle-tracking/students/$studentId/current-vehicle-location'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching vehicle location: $e');
      return null;
    }
  }

  Future<List<TripDTO>> getCompletedTrips() async {
    String url = '${AppConstants.baseUrl}${AppConstants.tripsEndpointComplete}';

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((model) => TripDTO.fromJson(model)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

}
