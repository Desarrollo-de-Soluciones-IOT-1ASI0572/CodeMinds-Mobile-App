import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:codeminds_mobile_application/core/app_constants.dart';
import 'package:codeminds_mobile_application/features/notification/data/remote/notification_dto.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<List<NotificationDTO>> getNotificationsByUserType(
    String userType,
  ) async {
    String url =
        '${AppConstants.baseUrl}${AppConstants.notificationsByUserTypeEndpoint}/$userType';
    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((model) => NotificationDTO.fromJson(model))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<NotificationDTO>> getNotificationsByUserId(int userId) async {
    String url =
        '${AppConstants.baseUrl}${AppConstants.notificationsByUserIdEndpoint}/$userId';
    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((model) => NotificationDTO.fromJson(model))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
