import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    this.surname,
    this.phone,
    this.role,
    this.active,
    this.gender,
    this.birthdate,
  });

  final String? surname;
  final String? phone;
  final String? role;
  final bool? active;
  final String? gender;
  final String? birthdate;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      surname: json['surname'],
      phone: json['phone'],
      role: json['role'],
      active: json['active'],
      gender: json['gender'],
      birthdate: json['birthdate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'phone': phone,
      'role': role,
      'active': active,
      'gender': gender,
      'birthdate': birthdate,
    };
  }
}
