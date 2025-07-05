class ProfileModel {
  final int? id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String address;
  final String gender;
  final String photoUrl;

  ProfileModel(
      {this.id,
      required this.fullName,
      required this.email,
      required this.mobileNumber,
      required this.address,
      required this.gender,
      required this.photoUrl});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobileNumber'] as String,
      address: json['address'] as String,
      gender: json['gender'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'address': address,
      'gender': gender,
      'photoUrl': photoUrl,
    };
  }
}
