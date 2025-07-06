
import '../../../assignments/domain/entities/student.dart';

class ActiveTripModel {
  final int id;
  final DateTime? startTime;
  final List<Student> students;

  ActiveTripModel({
    required this.id,
    this.startTime,
    required this.students,
  });

  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    return ActiveTripModel(
      id: json['id'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      students: (json['students'] as List)
          .map((student) => Student.fromJson(student))
          .toList(),
    );
  }
}
