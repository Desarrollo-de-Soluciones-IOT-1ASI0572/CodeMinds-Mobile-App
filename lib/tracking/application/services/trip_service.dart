import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:codeminds_mobile_application/shared/app_constants.dart';

import '../../domain/entities/location.dart';
import '../../infrastructure/remote/active_trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../infrastructure/remote/location_model.dart';
import '../../infrastructure/remote/trip_model.dart';

class TripService {
  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<int?> createTrip({
    required int vehicleId,
    required int driverId,
    required String origin,
    required String destination,
  }) async {
    final url = '${AppConstants.baseUrl}${AppConstants.tripsEndpoint}';

    debugPrint('''
🚀 [CREATE TRIP REQUEST DETAILS]
URL: $url
Headers: ${await _getHeaders()}
Body:
- vehicleId: $vehicleId
- driverId: $driverId
- origin: $origin
- destination: $destination
''');

    try {
      final requestBody = {
        'vehicleId': vehicleId,
        'driverId': driverId,
        'origin': origin,
        'destination': destination,
      };

      debugPrint('📦 Request Body JSON: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      // 3. Log detallado de la respuesta
      debugPrint('''
🔔 [CREATE TRIP RESPONSE]
Status Code: ${response.statusCode}
Headers: ${response.headers}
Body: ${response.body.isNotEmpty ? response.body : 'EMPTY RESPONSE'}
''');

      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
        final tripData = jsonDecode(response.body);
        debugPrint('✅ Viaje creado exitosamente. ID: ${tripData['id']}');
        return tripData['id'];
      } else {
        // 4. Análisis de errores específicos
        if (response.statusCode == 400) {
          debugPrint('''
❌ ERROR 400 DETAILS:
Possible causes:
1. Missing required fields
2. Invalid data format
3. Validation errors
4. Authentication issues

Server response: ${response.body.isNotEmpty ? response.body : 'No additional error message'}
''');

          try {
            final errorResponse = jsonDecode(response.body);
            debugPrint('🔍 Error details: $errorResponse');
          } catch (e) {
            debugPrint('⚠️ Could not parse error response body');
          }
        }
        return null;
      }
    } catch (e, stackTrace) {
      // 5. Log de excepciones completas
      debugPrint('''
❌ [CREATE TRIP EXCEPTION]
Error: $e
Stack Trace: $stackTrace
''');
      return null;
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
        '${AppConstants.baseUrl}/locations/trip/$tripId';
    debugPrint('🔍 Llamando a: $url');

    try {
      // ✅ Asegúrate de pasar el token en los headers
      http.Response response =
      await http.get(Uri.parse(url), headers: await _getHeaders());

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);

        final locations = jsonResponse
            .map((model) => Location.fromDTO(LocationModel.fromJson(model)))
            .toList();

        debugPrint(
            '📦 ${locations.length} ubicaciones recibidas para tripId=$tripId');

        for (var loc in locations) {
          debugPrint('📍 ${loc.latitude}, ${loc.longitude}');
        }

        return locations;
      }

      debugPrint(
          '⚠️ Respuesta no OK (${response.statusCode}) para tripId=$tripId');
      return [];
    } catch (e) {
      debugPrint('❌ Error al obtener ubicaciones para tripId=$tripId: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getCurrentVehicleLocation(int studentId) async {
    final url = '${AppConstants.baseUrl}/vehicles/students/$studentId/current-vehicle-location';
    debugPrint('🚗 Obteniendo ubicación del vehículo para estudiante $studentId');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      debugPrint('🔔 Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == HttpStatus.ok) {
        final data = jsonDecode(response.body);
        debugPrint('📍 Ubicación obtenida: ${data['location']}');
        return data;
      } else if (response.statusCode == HttpStatus.notFound) {
        debugPrint('⚠️ No se encontró viaje activo para el estudiante');
        throw Exception('No active trip found for student');
      } else {
        debugPrint('❌ Error del servidor: ${response.statusCode}');
        throw Exception('Failed to fetch vehicle location');
      }
    } catch (e) {
      debugPrint('❌ Excepción al obtener ubicación: $e');
      throw Exception('Error fetching vehicle location: $e');
    }
  }

  Future<List<TripModel>> getCompletedTripsByDriver(int driverId) async {
    final url =
        '${AppConstants.baseUrl}${AppConstants.completedTripsByDriverEndpoint}/$driverId';
    debugPrint('🌐 Calling: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TripModel.fromJson(json)).toList();
      }
      debugPrint('⚠️ Error ${response.statusCode}: ${response.body}');
      throw Exception(
          'Failed to load trips. Status code: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Error in getCompletedTripsByDriver: $e');
      throw Exception('Failed to load trips: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTripStudents(int tripId) async {
    final url = '${AppConstants.baseUrl}${AppConstants.tripStudentsEndpoint}/$tripId/students';
    debugPrint('📘 Llamando a: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ ${data.length} estudiantes recibidos para tripId=$tripId');
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint('⚠️ Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error al obtener estudiantes: $e');
      return [];
    }
  }

  Future<List<ActiveTripModel>> getActiveTripByDriver(int driverId) async {
    final url =
        '${AppConstants.baseUrl}/trips/active/driver/$driverId';
    debugPrint('🌐 Calling active trip endpoint: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ActiveTripModel.fromJson(json)).toList();
      } else if (response.statusCode == HttpStatus.notFound) {
        return [];
      } else {
        debugPrint('⚠️ Error ${response.statusCode}: ${response.body}');
        throw Exception(
            'Failed to load active trip. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in getActiveTripByDriver: $e');
      throw Exception('Failed to load active trip: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> startTrip(int tripId) async {
    final url = '${AppConstants.baseUrl}/trips/$tripId/start'; // URL modificada con tripId en la URI
    debugPrint('🚦 Intentando iniciar viaje ID: $tripId en $url');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      debugPrint('🔔 Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
        debugPrint('✅ Viaje $tripId iniciado con éxito. Estado: ${jsonDecode(response.body)['status']}');
        return true;
      } else {
        debugPrint('❌ Error al iniciar viaje. Código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al iniciar viaje: $e');
      return false;
    }
  }

  Future<bool> endTrip(int tripId) async {
    final url = '${AppConstants.baseUrl}/trips/$tripId/end'; // URL modificada con tripId en la URI
    debugPrint('🛑 Intentando finalizar viaje ID: $tripId en $url');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      debugPrint('🔔 Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.accepted) {
        debugPrint('✅ Viaje $tripId finalizado correctamente');
        return true;
      } else {
        debugPrint('❌ Error al finalizar viaje. Código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al finalizar viaje: $e');
      return false;
    }
  }

  Future<bool> updateStudentAttendance({
    required int tripId,
    required int studentId,
    required bool attended,
    DateTime? boardedAt,
    DateTime? exitedAt,
  }) async {
    final url = '${AppConstants.baseUrl}${AppConstants.tripStudentsEndpoint}/$tripId/students/$studentId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode({
          'attended': attended,
          if (boardedAt != null) 'boardedAt': boardedAt.toIso8601String(),
          if (exitedAt != null) 'exitedAt': exitedAt.toIso8601String(),
        }),
      );
      return response.statusCode == HttpStatus.ok;
    } catch (e) {
      debugPrint('❌ Error al actualizar asistencia: $e');
      return false;
    }
  }




}
