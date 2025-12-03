import 'package:flutter_task/data/datasources/remote/personnel_remote_data_source.dart';
import 'package:flutter_task/data/models/personnel_model.dart';
import 'package:flutter_task/data/models/role_model.dart';
import 'package:flutter_task/domain/repositories/personnel_repository.dart';

class PersonnelRepositoryImpl implements PersonnelRepository {
  final PersonnelRemoteDataSource _remoteDataSource;

  PersonnelRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PersonnelModel>> getPersonnelList({int? userId}) async {
    try {
      return await _remoteDataSource.getPersonnelList(userId: userId);
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to load personnel list: $e');
    }
  }

  @override
  Future<PersonnelModel> getPersonnelDetails(int id) async {
    try {
      return await _remoteDataSource.getPersonnelDetails(id);
    } catch (e) {
      throw Exception('Failed to load personnel details: $e');
    }
  }

  @override
  Future<void> addPersonnel(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.addPersonnel(data);
    } catch (e) {
      throw Exception('Failed to add personnel: $e');
    }
  }

  @override
  Future<void> updatePersonnel(int id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updatePersonnel(id, data);
    } catch (e) {
      throw Exception('Failed to update personnel: $e');
    }
  }

  @override
  Future<void> updatePersonnelStatus(int id) async {
    try {
      await _remoteDataSource.updatePersonnelStatus(id);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  @override
  Future<List<RoleModel>> getApiaryRoles() async {
    try {
      return await _remoteDataSource.getApiaryRoles();
    } catch (e) {
      throw Exception('Failed to load roles: $e');
    }
  }
}