class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final String? dateOfBirth;
  final String? referenceCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    this.dateOfBirth,
    this.referenceCode,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phonenumber'] ?? '',
      profileImage: json['profile_image'],
      dateOfBirth: json['date_of_birth'],
      referenceCode: json['reference_code'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'date_of_birth': dateOfBirth,
      'reference_code': referenceCode,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 