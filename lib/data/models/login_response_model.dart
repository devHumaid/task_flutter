// lib/data/models/login_response_model.dart

class LoginResponseModel {
  final bool status;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  final String? message;
  
  LoginResponseModel({
    required this.status,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.message,
  });
  
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] ?? false,
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}

class UserModel {
  final int id;
  final int roleId;
  final String role;
  final String firstName;
  final String? lastName;
  final String? profileImageUrl;
  
  UserModel({
    required this.id,
    required this.roleId,
    required this.role,
    required this.firstName,
    this.lastName,
    this.profileImageUrl,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int from dynamic value
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return UserModel(
      id: _parseInt(json['id']),                  // Fixed: Handle String or int
      roleId: _parseInt(json['role_id']),         // Fixed: Handle String or int
      role: json['role']?.toString() ?? '',       // Fixed: Ensure String
      firstName: json['first_name']?.toString() ?? '',  // Fixed: Ensure String
      lastName: json['last_name']?.toString(),     // Fixed: Ensure String
      profileImageUrl: json['profile_image_url']?.toString(),  // Fixed: Ensure String
    );
  }
  
  String get fullName => '$firstName ${lastName ?? ''}'.trim();
}