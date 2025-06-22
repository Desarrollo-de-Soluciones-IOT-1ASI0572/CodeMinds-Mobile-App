import 'dart:convert';
import 'dart:io';
import 'package:codeminds_mobile_application/features/profiles/data/remote/profile.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl =
      'https://edugo-service-de983aa97099.herokuapp.com/api/v1';

  Future<ProfileModel> fetchProfile(int userId) async {
    String? token = await getToken();
    http.Response response;

    if (token != null) {
      final url = Uri.parse('$baseUrl/profiles/user/$userId');
      response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } else {
      print('Token no encontrado. Por favor, inicia sesión.');
      throw Exception('Token no encontrado');
    }

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == HttpStatus.ok) {
      Map<String, dynamic> json = jsonDecode(response.body);
      return ProfileModel.fromJson(json);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      print('Error 401: No autorizado');
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al obtener el perfil');
    }
  }

  Future<bool> createProfile(ProfileModel profile) async {
    String? token = await getToken();
    http.Response response;

    if (token != null) {
      final url = Uri.parse('$baseUrl/profiles');
      response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profile.toJson()),
      );
    } else {
      print('Token no encontrado. Por favor, inicia sesión.');
      throw Exception('Token no encontrado');
    }

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == HttpStatus.created) {
      return true;
    } else if (response.statusCode == HttpStatus.unauthorized) {
      print('Error 401: No autorizado');
      throw Exception('No autorizado');
    } else {
      throw Exception('Error al crear el perfil');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
