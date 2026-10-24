class User {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String profession;
  final String? gender;
  final String? dateOfBirth;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String country;
  final String state;
  final String city;
  final String? profilePhotoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profession,
    this.gender,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
    required this.country,
    required this.state,
    required this.city,
    this.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      profession: json['profession'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      country: json['country'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }
}

//This is where your entity fields matter.
