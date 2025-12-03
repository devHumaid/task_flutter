import 'package:flutter_task/core/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  
  LocalStorageService(this._prefs, this._secureStorage);
  
  // Auth Token (Secure Storage)
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: StorageKeys.authToken, value: token);
  }
  
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: StorageKeys.authToken);
  }
  
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }
  
  // Remember Me
  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(StorageKeys.rememberMe, value);
  }
  
  bool getRememberMe() {
    return _prefs.getBool(StorageKeys.rememberMe) ?? false;
  }
  
  Future<void> saveEmail(String email) async {
    await _prefs.setString(StorageKeys.savedEmail, email);
  }
  
  String? getSavedEmail() {
    return _prefs.getString(StorageKeys.savedEmail);
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}