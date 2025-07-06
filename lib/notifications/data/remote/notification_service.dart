import 'dart:convert';
import 'dart:io';

import 'package:codeminds_mobile_application/shared/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_dto.dart';


class NotificationService {
  Future<List<NotificationDTO>> getNotificationsByUserType(
    String userType,
  ) async {
    String? token = await getToken();
    http.Response response;

    if (token != null) {
      String url =
          '${AppConstants.baseUrl}${AppConstants.notificationsByUserTypeEndpoint}/$userType';
      try {
        response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        return [];
      }
    } else {
      print('Token no encontrado. Por favor, inicia sesión.');
      throw Exception('Token no encontrado');
    }

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((model) => NotificationDTO.fromJson(model))
          .toList();
    } else if (response.statusCode == HttpStatus.unauthorized) {
      print('Error 401: No autorizado');
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al obtener las notificaciones');
    }
  }

  Future<List<NotificationDTO>> getNotificationsByUserId(int userId) async {
    String? token = await getToken();
    http.Response response;

    if (token != null) {
      String url =
          '${AppConstants.baseUrl}${AppConstants.notificationsByUserIdEndpoint}/$userId';
      try {
        response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        return [];
      }
    } else {
      print('Token no encontrado. Por favor, inicia sesión.');
      throw Exception('Token no encontrado');
    }

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((model) => NotificationDTO.fromJson(model))
          .toList();
    } else if (response.statusCode == HttpStatus.unauthorized) {
      print('Error 401: No autorizado');
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al obtener las notificaciones');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
