import 'user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final UserModel user;

  const LoginResponseModel({
    required this.accessToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}
