// lib/data/models/personnel_model.dart

import 'package:flutter_task/data/models/role_model.dart';

class PersonnelModel {
  final int id;
  final String firstName;
  final String? lastName;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? suburb;
  final String? state;
  final String? postcode;
  final String? country;
  final String? contactNumber;
  final String? additionalNotes;
  final int status;
  final List<String>? roleIds;
  final int? createdBy;
  final int? updatedBy;
  final List<RoleModel>? roleDetails; // Changed from single role to list
  final List<dynamic>? apiaryRoleArray;

  PersonnelModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.address,
    this.latitude,
    this.longitude,
    this.suburb,
    this.state,
    this.postcode,
    this.country,
    this.contactNumber,
    this.additionalNotes,
    required this.status,
    this.roleIds,
    this.createdBy,
    this.updatedBy,
    this.roleDetails,
    this.apiaryRoleArray,
  });

  factory PersonnelModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing PersonnelModel: $json'); // Debug print
      
      // Parse role_details array
      List<RoleModel>? parsedRoles;
      if (json['role_details'] != null && json['role_details'] is List) {
        try {
          parsedRoles = (json['role_details'] as List)
              .map((roleJson) => RoleModel.fromJson(roleJson as Map<String, dynamic>))
              .toList();
          print('Roles parsed successfully: ${parsedRoles.length} roles'); // Debug print
        } catch (e) {
          print('Error parsing role_details: $e'); // Debug print
        }
      }

      // Parse role_ids array
      List<String>? parsedRoleIds;
      if (json['role_ids'] != null && json['role_ids'] is List) {
        parsedRoleIds = (json['role_ids'] as List).map((e) => e.toString()).toList();
      }

      return PersonnelModel(
        id: _parseToInt(json['id']),
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String?,
        address: json['address'] as String?,
        latitude: json['latitude']?.toString(),
        longitude: json['longitude']?.toString(),
        suburb: json['suburb'] as String?,
        state: json['state'] as String?,
        postcode: json['postcode'] as String?,
        country: json['country'] as String?,
        contactNumber: json['contact_number'] as String?,
        additionalNotes: json['additional_notes'] as String?,
        status: _parseToInt(json['status']),
        roleIds: parsedRoleIds,
        createdBy: json['created_by'] != null ? _parseToInt(json['created_by']) : null,
        updatedBy: json['updated_by'] != null ? _parseToInt(json['updated_by']) : null,
        roleDetails: parsedRoles,
        apiaryRoleArray: json['apiary_role_array'] as List?,
      );
    } catch (e) {
      print('Error parsing PersonnelModel: $e');
      print('JSON data: $json');
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

  // Helper getter to get primary role (first role in the list)
  RoleModel? get primaryRole => roleDetails?.isNotEmpty == true ? roleDetails!.first : null;

  // Helper getter to get all role names as a comma-separated string
  String get roleNames => roleDetails?.map((r) => r.role).join(', ') ?? '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'suburb': suburb,
      'state': state,
      'postcode': postcode,
      'country': country,
      'contact_number': contactNumber,
      'additional_notes': additionalNotes,
      'status': status,
      'role_ids': roleIds,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'role_details': roleDetails?.map((r) => r.toJson()).toList(),
      'apiary_role_array': apiaryRoleArray,
    };
  }
}