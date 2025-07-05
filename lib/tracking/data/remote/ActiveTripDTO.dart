import 'StudentDTO.dart';

class ActiveTripDTO {
  final int id;
  final DateTime? startTime; // 👈 Nullable!
  final List<StudentDTO> students;

  ActiveTripDTO({
    required this.id,
    this.startTime, // 👈 Nullable!
    required this.students,
  });

  factory ActiveTripDTO.fromJson(Map<String, dynamic> json) {
    return ActiveTripDTO(
      id: json['id'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      students: (json['students'] as List)
          .map((student) => StudentDTO.fromJson(student))
          .toList(),
    );
  }
}
