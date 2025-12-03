import 'package:flutter_task/data/models/login_response_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login(String email, String password);
  Future<void> saveCredentials(String token, String refreshToken);
  Future<void> logout();
}