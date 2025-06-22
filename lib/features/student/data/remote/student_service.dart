import 'dart:convert';
import 'dart:io';
import 'package:codeminds_mobile_application/features/student/data/remote/student.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentService {
  final String baseUrl =
      'https://edugo-service-de983aa97099.herokuapp.com/api/v1';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<StudentModel>> getAllStudents() async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('$baseUrl/students/all');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => StudentModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los estudiantes');
    }
  }

  Future<StudentModel> getStudentById(int id) async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('$baseUrl/students/$id');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return StudentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener el estudiante');
    }
  }

  Future<StudentModel> postStudent(StudentModel student, int parentId) async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('$baseUrl/students/create');
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
      return StudentModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el estudiante');
    }
  }

  Future<List<StudentModel>> getStudentsByParentUserId(int parentUserId) async {
    String? token = await getToken();
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('$baseUrl/students/all');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> jsonList = jsonDecode(response.body);
      // Filtrar los estudiantes cuyo parentProfile.userId coincide con parentUserId
      return jsonList
          .map((e) => StudentModel.fromJson(e))
          .where((student) =>
              student.parentProfile != null &&
              student.parentProfile!.userId == parentUserId)
          .toList();
    } else {
      throw Exception('Error al obtener los estudiantes');
    }
  }
}
