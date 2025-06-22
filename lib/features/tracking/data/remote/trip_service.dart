import 'dart:convert';
import 'dart:io';
import 'package:codeminds_mobile_application/features/tracking/data/remote/location_dto.dart';
import 'package:codeminds_mobile_application/features/tracking/data/remote/trip_dto.dart';
import 'package:codeminds_mobile_application/features/tracking/domain/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:codeminds_mobile_application/core/app_constants.dart';

import 'ActiveTripDTO.dart';

class TripService {

  late final String? authToken;

  TripService({this.authToken});

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
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
    final url = '${AppConstants.baseUrl}/vehicle-tracking/locations/trip/$tripId';
    debugPrint('🔍 Llamando a: $url');

    try {
      // ✅ Asegúrate de pasar el token en los headers
      http.Response response = await http.get(Uri.parse(url), headers: _getHeaders());

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);

        final locations = jsonResponse
            .map((model) => Location.fromDTO(LocationDTO.fromJson(model)))
            .toList();

        debugPrint('📦 ${locations.length} ubicaciones recibidas para tripId=$tripId');

        for (var loc in locations) {
          debugPrint('📍 ${loc.latitude}, ${loc.longitude}');
        }

        return locations;
      }

      debugPrint('⚠️ Respuesta no OK (${response.statusCode}) para tripId=$tripId');
      return [];
    } catch (e) {
      debugPrint('❌ Error al obtener ubicaciones para tripId=$tripId: $e');
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

  Future<List<TripDTO>> getCompletedTripsByDriver(int driverId) async {
    final url = '${AppConstants.baseUrl}${AppConstants.completedTripsByDriverEndpoint}/$driverId';
    debugPrint('🌐 Calling: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TripDTO.fromJson(json)).toList();
      }
      debugPrint('⚠️ Error ${response.statusCode}: ${response.body}');
      throw Exception('Failed to load trips. Status code: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in getCompletedTripsByDriver: $e');
      throw Exception('Failed to load trips: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTripStudents(int tripId) async {
    final url = '${AppConstants.baseUrl}/vehicle-tracking/trips/$tripId/students';
    debugPrint('📘 Llamando a: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ ${data.length} estudiantes recibidos para tripId=$tripId');
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint('⚠️ Respuesta no OK (${response.statusCode}) al obtener estudiantes');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error al obtener estudiantes del viaje $tripId: $e');
      return [];
    }
  }

  Future<List<ActiveTripDTO>> getActiveTripByDriver(int driverId) async {
    final url = '${AppConstants.baseUrl}/vehicle-tracking/trips/active/driver/$driverId';
    debugPrint('🌐 Calling active trip endpoint: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ActiveTripDTO.fromJson(json)).toList();
      } else if (response.statusCode == HttpStatus.notFound) {
        return []; // Retorna lista vacía si no hay viaje activo
      } else {
        debugPrint('⚠️ Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load active trip. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in getActiveTripByDriver: $e');
      throw Exception('Failed to load active trip: $e');
    }
  }
}

