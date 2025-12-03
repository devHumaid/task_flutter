// lib/data/datasources/remote/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/network/api_client.dart';
import 'package:flutter_task/data/models/login_request_model.dart';
import 'package:flutter_task/data/models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  
  AuthRemoteDataSourceImpl(this._apiClient);
  
  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      print('🌐 Making login request to: ${ApiConstants.baseUrl}${ApiConstants.login}');
      print('📤 Request data: ${request.toFormData()}');
      
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: FormData.fromMap(request.toFormData()),
      );
      
      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response data type: ${response.data.runtimeType}');
      print('📥 Full response data:');
      print(response.data);
      
      // Check if response is successful
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        
        // Debug each field
        print('🔍 Parsing response...');
        print('  - status: ${data['status']} (${data['status'].runtimeType})');
        print('  - access_token: ${data['access_token']?.substring(0, 20)}... (${data['access_token'].runtimeType})');
        
        if (data['user'] != null) {
          print('  - user data:');
          final user = data['user'] as Map<String, dynamic>;
          print('    - id: ${user['id']} (${user['id'].runtimeType})');
          print('    - role_id: ${user['role_id']} (${user['role_id'].runtimeType})');
          print('    - role: ${user['role']} (${user['role'].runtimeType})');
          print('    - first_name: ${user['first_name']} (${user['first_name'].runtimeType})');
        }
        
        print('🔧 Creating LoginResponseModel...');
        final loginResponse = LoginResponseModel.fromJson(data);
        print('✅ LoginResponseModel created successfully');
        
        return loginResponse;
      } else {
        throw Exception('Invalid response format: expected Map but got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('❌ DioException type: ${e.type}');
      print('❌ DioException message: ${e.message}');
      
      if (e.response != null) {
        print('❌ Response status code: ${e.response!.statusCode}');
        print('❌ Response data: ${e.response!.data}');
        
        final data = e.response!.data;
        
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Login failed');
        } else {
          throw Exception('Login failed with status code: ${e.response!.statusCode}');
        }
      } else {
        throw Exception('Network error. Please check your internet connection.');
      }
    } catch (e, stackTrace) {
      print('❌ Unexpected error: $e');
      print('❌ Stack trace: $stackTrace');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}