// lib/domain/repositories/personnel_repository.dart

import 'package:flutter_task/data/models/personnel_model.dart';
import 'package:flutter_task/data/models/role_model.dart';

abstract class PersonnelRepository {
  Future<List<PersonnelModel>> getPersonnelList({int? userId});
  Future<PersonnelModel> getPersonnelDetails(int id);
  Future<void> addPersonnel(Map<String, dynamic> data);
  Future<void> updatePersonnel(int id, Map<String, dynamic> data);
  Future<void> updatePersonnelStatus(int id);
  Future<List<RoleModel>> getApiaryRoles();
}

