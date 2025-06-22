import 'StudentDTO.dart';

class ActiveTripDTO {
  final int id;
  final DateTime startTime;
  final List<StudentDTO> students;

  ActiveTripDTO({
    required this.id,
    required this.startTime,
    required this.students,
  });

  factory ActiveTripDTO.fromJson(Map<String, dynamic> json) {
    return ActiveTripDTO(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      students: (json['students'] as List)
          .map((student) => StudentDTO.fromJson(student))
          .toList(),
    );
  }
}