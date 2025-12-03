// lib/injection_container.dart

import 'package:dio/dio.dart';
import 'package:flutter_task/core/network/api_client.dart';
import 'package:flutter_task/data/datasources/local/local_storage_service.dart';
import 'package:flutter_task/data/datasources/remote/auth_remote_datasource.dart';
import 'package:flutter_task/data/datasources/remote/personnel_remote_data_source.dart';
import 'package:flutter_task/domain/repositories/auth_repository.dart';
import 'package:flutter_task/domain/repositories/auth_repository_impl.dart';
import 'package:flutter_task/domain/repositories/personnel_repository.dart';
import 'package:flutter_task/domain/repositories/personnel_repository_impl.dart';
import 'package:flutter_task/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  sl.registerLazySingleton(() => secureStorage);
  
  // Register Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://beechem.ishtech.live/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors for logging and token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage and add to headers
          final token = await sl<FlutterSecureStorage>().read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally if needed
          return handler.next(error);
        },
      ),
    );
    
    return dio;
  });
  
  // Core
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(sl(), sl()),
  );
  
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl()),
  );
  
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  
  sl.registerLazySingleton<PersonnelRemoteDataSource>(
    () => PersonnelRemoteDataSourceImpl(dio: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  
  sl.registerLazySingleton<PersonnelRepository>(
    () => PersonnelRepositoryImpl(sl()),
  );
  
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(sl(), sl()),
  );
  
  sl.registerFactory(
    () => PersonnelBloc(sl()),
  );
}