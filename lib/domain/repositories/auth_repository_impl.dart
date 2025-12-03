import 'package:flutter_task/data/datasources/local/local_storage_service.dart';
import 'package:flutter_task/data/datasources/remote/auth_remote_datasource.dart';
import 'package:flutter_task/data/models/login_request_model.dart';
import 'package:flutter_task/data/models/login_response_model.dart';
import 'package:flutter_task/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorage;
  
  AuthRepositoryImpl(this._remoteDataSource, this._localStorage);
  
  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final request = LoginRequestModel(
      email: email,
      password: password,
    );
    
    return await _remoteDataSource.login(request);
  }
  
  @override
  Future<void> saveCredentials(String token, String refreshToken) async {
    await _localStorage.saveAuthToken(token);
    await _localStorage.saveRefreshToken(refreshToken);
  }
  
  @override
  Future<void> logout() async {
    await _localStorage.clearAll();
  }
}
