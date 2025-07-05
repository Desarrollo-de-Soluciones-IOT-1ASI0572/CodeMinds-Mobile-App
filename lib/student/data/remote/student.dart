class StudentModel {
  final int id;
  final String name;
  final String lastName;
  final String homeAddress;
  final String schoolAddress;
  final String studentPhotoUrl;
  final Wristband? wristband;
  final ParentProfile? parentProfile;

  StudentModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.homeAddress,
    required this.schoolAddress,
    required this.studentPhotoUrl,
    this.wristband,
    this.parentProfile,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      name: json['name'],
      lastName: json['lastName'],
      homeAddress: json['homeAddress'],
      schoolAddress: json['schoolAddress'],
      studentPhotoUrl: json['studentPhotoUrl'],
      wristband: json['wristband'] != null
          ? Wristband.fromJson(json['wristband'])
          : null,
      parentProfile: json['parentProfile'] != null
          ? ParentProfile.fromJson(json['parentProfile'])
          : null,
    );
  }
}

class Wristband {
  final int id;
  final String rfidCode;
  final String wristbandStatus;
  final StudentModel? student;
  final List<dynamic> sensorScans;

  Wristband({
    required this.id,
    required this.rfidCode,
    required this.wristbandStatus,
    this.student,
    required this.sensorScans,
  });

  factory Wristband.fromJson(Map<String, dynamic> json) {
    return Wristband(
      id: json['id'],
      rfidCode: json['rfidCode'],
      wristbandStatus: json['wristbandStatus'],
      student: json['student'] != null
          ? StudentModel.fromJson(json['student'])
          : null,
      sensorScans: json['sensorScans'] ?? [],
    );
  }
}

class ParentProfile {
  final int id;
  final int userId;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String address;
  final String gender;
  final String photoUrl;
  final String role;

  ParentProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.gender,
    required this.photoUrl,
    required this.role,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      address: json['address'],
      gender: json['gender'],
      photoUrl: json['photoUrl'],
      role: json['role'],
    );
  }
}
