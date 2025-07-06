import 'dart:convert';
import 'dart:io';
import 'package:codeminds_mobile_application/assignments/domain/entities/student.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/app_constants.dart';

class StudentService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<Student>> getAllStudents() async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('${AppConstants.baseUrl}/students');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Student.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los estudiantes');
    }
  }

  Future<Student> getStudentById(int id) async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('${AppConstants.baseUrl}/students/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener el estudiante');
    }
  }

  Future<Student> postStudent(Student student, int parentId) async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('${AppConstants.baseUrl}/students');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "name": student.name,
        "lastName": student.lastName,
        "homeAddress": student.homeAddress,
        "schoolAddress": student.schoolAddress,
        "studentPhotoUrl": student.studentPhotoUrl,
        "parentProfileId": parentId
      }),
    );

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      return Student.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el estudiante');
    }
  }

  Future<List<Student>> getStudentsByParentUserId(int parentUserId) async {
    try {
      String? token = await getToken();
      if (token == null) {
        print('🔴 Error: Token no encontrado');
        throw Exception('Token no encontrado');
      }

      final url = Uri.parse('${AppConstants.baseUrl}/students');
      print('🔵 Solicitando estudiantes para parentUserId: $parentUserId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🟠 Respuesta recibida - Status: ${response.statusCode}');

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> jsonList = jsonDecode(response.body);
        print('🟢 Estudiantes recibidos: ${jsonList.length}');

        final students = jsonList
            .map((e) => Student.fromJson(e))
            .where((student) => student.parentProfileId == parentUserId)
            .toList();

        print('🟢 Estudiantes filtrados: ${students.length}');
        return students;
      } else {
        print('🔴 Error en la respuesta: ${response.statusCode}');
        throw Exception('Error al obtener los estudiantes');
      }
    } catch (e) {
      print('🔴 Error en getStudentsByParentUserId: $e');
      rethrow;
    }
  }
}