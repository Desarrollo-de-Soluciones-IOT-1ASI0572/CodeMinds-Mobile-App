class StudentDTO {
  final int id;
  final String name;
  final String lastName;
  final String homeAddress;
  final String schoolAddress;
  final String studentPhotoUrl;

  StudentDTO({
    required this.id,
    required this.name,
    required this.lastName,
    required this.homeAddress,
    required this.schoolAddress,
    required this.studentPhotoUrl,
  });

  factory StudentDTO.fromJson(Map<String, dynamic> json) {
    return StudentDTO(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      homeAddress: json['homeAddress'],
      schoolAddress: json['schoolAddress'],
      studentPhotoUrl: json['studentPhotoUrl'],
    );
  }
}