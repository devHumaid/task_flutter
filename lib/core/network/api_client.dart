import 'package:dio/dio.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/data/datasources/local/local_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final LocalStorageService _localStorage;
  
  ApiClient(this._localStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _localStorage.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          return handler.next(error);
        },
      ),
    );
  }
  
  Dio get dio => _dio;
}