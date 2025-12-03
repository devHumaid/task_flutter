// lib/data/datasources/remote/personnel_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:flutter_task/data/models/personnel_model.dart';
import 'package:flutter_task/data/models/role_model.dart';

abstract class PersonnelRemoteDataSource {
  Future<List<PersonnelModel>> getPersonnelList({int? userId});
  Future<PersonnelModel> getPersonnelDetails(int id);
  Future<void> addPersonnel(Map<String, dynamic> data);
  Future<void> updatePersonnel(int id, Map<String, dynamic> data);
  Future<void> updatePersonnelStatus(int id);
  Future<List<RoleModel>> getApiaryRoles();
  Future<List<Map<String, dynamic>>> getInspectorDropdown(int id);
}

class PersonnelRemoteDataSourceImpl implements PersonnelRemoteDataSource {
  final Dio dio;

  PersonnelRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PersonnelModel>> getPersonnelList({int? userId}) async {
    try {
      final queryParams = userId != null ? {'user_id': userId} : null;
      final response = await dio.get(
        '/personnel-details',
        queryParameters: queryParams,
      );

      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PersonnelModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load personnel list');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching personnel list: $e');
    }
  }

  @override
  Future<PersonnelModel> getPersonnelDetails(int id) async {
    try {
      final response = await dio.get('/personnel-details/$id');

      if (response.data['status'] == true && response.data['data'] != null) {
        return PersonnelModel.fromJson(response.data['data']);
      } else {
        throw Exception('Personnel details not found');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching personnel details: $e');
    }
  }

  @override
  Future<void> addPersonnel(Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await dio.post(
        '/personnel-details/add',
        data: formData,
      );

      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to add personnel');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error adding personnel: $e');
    }
  }

  @override
  Future<void> updatePersonnel(int id, Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      final response = await dio.post(
        '/personnel-details/$id',
        data: formData,
      );

      if (response.data['status'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to update personnel');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating personnel: $e');
    }
  }

  @override
  Future<void> updatePersonnelStatus(int id) async {
    try {
      final response = await dio.post('/personnel-details/$id/status');

      if (response.data['status'] != true) {
        throw Exception(
            response.data['message'] ?? 'Failed to update status');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error updating personnel status: $e');
    }
  }

  @override
  Future<List<RoleModel>> getApiaryRoles() async {
    try {
      print('Fetching roles from API...'); // Debug
      final response = await dio.get('/roles/apiary-roles');
      
      print('Response status code: ${response.statusCode}'); // Debug
      print('Response data: ${response.data}'); // Debug

      if (response.data is List) {
        final roles = (response.data as List)
            .map((json) {
              try {
                return RoleModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing role: $json, Error: $e'); // Debug
                rethrow;
              }
            })
            .toList();
        
        print('Successfully parsed ${roles.length} roles'); // Debug
        return roles;
      } else {
        throw Exception('Invalid response format: expected List, got ${response.data.runtimeType}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}'); // Debug
      print('Response: ${e.response?.data}'); // Debug
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('General error: $e'); // Debug
      throw Exception('Error fetching roles: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInspectorDropdown(int id) async {
    try {
      final response = await dio.get('/personnel-details/$id/dropdown');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching inspector dropdown: $e');
    }
  }
}