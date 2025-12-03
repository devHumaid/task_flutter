import 'package:equatable/equatable.dart';
import 'package:flutter_task/data/models/personnel_model.dart';
import 'package:flutter_task/data/models/role_model.dart';

abstract class PersonnelState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PersonnelInitial extends PersonnelState {}

class PersonnelLoading extends PersonnelState {}

class PersonnelListLoaded extends PersonnelState {
  final List<PersonnelModel> personnelList;
  final String? searchQuery;

  PersonnelListLoaded(this.personnelList, {this.searchQuery});

  List<PersonnelModel> get filteredList {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return personnelList;
    }
    return personnelList
        .where((p) =>
            p.firstName.toLowerCase().contains(searchQuery!.toLowerCase()))
        .toList();
  }

  @override
  List<Object?> get props => [personnelList, searchQuery];
}

class PersonnelDetailsLoaded extends PersonnelState {
  final PersonnelModel personnel;

  PersonnelDetailsLoaded(this.personnel);

  @override
  List<Object?> get props => [personnel];
}

class RolesLoaded extends PersonnelState {
  final List<RoleModel> roles;

  RolesLoaded(this.roles);

  @override
  List<Object?> get props => [roles];
}

class PersonnelOperationSuccess extends PersonnelState {
  final String message;

  PersonnelOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PersonnelError extends PersonnelState {
  final String message;

  PersonnelError(this.message);

  @override
  List<Object?> get props => [message];
}