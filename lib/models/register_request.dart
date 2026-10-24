import 'package:image_picker/image_picker.dart';

class RegisterRequest {
  final String name;
  final String email;
  final String mobile;
  final String password;
  final String profession;
  final String? gender;
  final String? dateOfBirth;
  final String country;
  final String state;
  final String city;
  final XFile? profilePhoto;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.profession,
    this.gender,
    this.dateOfBirth,
    required this.country,
    required this.state,
    required this.city,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'profession': profession,
      'country': country,
      'state': state,
      'city': city,
    };

    if (gender != null && gender!.isNotEmpty) {
      data['gender'] = gender;
    }

    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      data['dateOfBirth'] = dateOfBirth;
    }

    return data;
  }
}
