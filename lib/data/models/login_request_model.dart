class LoginRequestModel {
  final String email;
  final String password;
  final String mobUser;
  
  LoginRequestModel({
    required this.email,
    required this.password,
    this.mobUser = '1',
  });
  
  Map<String, dynamic> toFormData() {
    return {
      'email': email,
      'password': password,
      'mob_user': mobUser,
    };
  }
}
