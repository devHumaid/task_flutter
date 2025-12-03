import 'package:equatable/equatable.dart';

abstract class PersonnelEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPersonnelList extends PersonnelEvent {
  final int? userId;
  final String? searchQuery;

  LoadPersonnelList({this.userId, this.searchQuery});

  @override
  List<Object?> get props => [userId, searchQuery];
}

class LoadPersonnelDetails extends PersonnelEvent {
  final int id;

  LoadPersonnelDetails(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadRoles extends PersonnelEvent {}

class AddPersonnel extends PersonnelEvent {
  final Map<String, dynamic> data;

  AddPersonnel(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdatePersonnel extends PersonnelEvent {
  final int id;
  final Map<String, dynamic> data;

  UpdatePersonnel(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class UpdatePersonnelStatus extends PersonnelEvent {
  final int id;

  UpdatePersonnelStatus(this.id);

  @override
  List<Object?> get props => [id];
}
