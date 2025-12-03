// lib/data/models/role_model.dart

class RoleModel {
  final int id;
  final String role;
  final int? status;
  final int? defaultRole;
  final int? createdBy;

  RoleModel({
    required this.id,
    required this.role,
    this.status,
    this.defaultRole,
    this.createdBy,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing RoleModel: $json'); // Debug print
      
      return RoleModel(
        id: _parseToInt(json['id']),
        role: json['role'] as String? ?? '',
        status: json['status'] != null ? _parseToInt(json['status']) : null,
        defaultRole: json['default'] != null ? _parseToInt(json['default']) : null,
        createdBy: json['created_by'] != null ? _parseToInt(json['created_by']) : null,
      );
    } catch (e) {
      print('Error in RoleModel.fromJson: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  // Helper method to safely parse to int
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      if (status != null) 'status': status,
      if (defaultRole != null) 'default': defaultRole,
      if (createdBy != null) 'created_by': createdBy,
    };
  }
}