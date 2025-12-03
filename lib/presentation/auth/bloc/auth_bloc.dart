// lib/presentation/auth/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/data/datasources/local/local_storage_service.dart';
import 'package:flutter_task/domain/repositories/auth_repository.dart';
import 'package:flutter_task/presentation/auth/bloc/auth_event.dart';
import 'package:flutter_task/presentation/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;
  
  AuthBloc(this._authRepository, this._localStorage) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<CheckLoginStatus>(_onCheckLoginStatus);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Save email if remember me is checked
      if (event.rememberMe) {
        await _localStorage.setRememberMe(true);
        await _localStorage.saveEmail(event.email);
      } else {
        await _localStorage.setRememberMe(false);
      }
      
      // Add debug print
      print('🔑 Attempting login with email: ${event.email}');
      
      // Attempt login
      final response = await _authRepository.login(
        event.email,
        event.password,
      );
      
      // Add debug print
      print('📡 Response status: ${response.status}');
      print('📡 Response token: ${response.accessToken?.substring(0, 20)}...');
      
      if (response.status && response.accessToken != null) {
        // Save tokens
        await _authRepository.saveCredentials(
          response.accessToken!,
          response.refreshToken ?? '',
        );
        
        print('✅ Login successful');
        emit(AuthAuthenticated(response.user!));
      } else {
        print('❌ Login failed: ${response.message}');
        emit(AuthError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      print('❌ Login error: $e');
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthError(errorMessage));
    }
  }
  
  Future<void> _onCheckLoginStatus(
    CheckLoginStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _localStorage.isLoggedIn();
    
    if (isLoggedIn) {
      // In real app, validate token or fetch user data
      emit(AuthInitial());
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}