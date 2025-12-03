import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task/domain/repositories/personnel_repository.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_event.dart';
import 'package:flutter_task/presentation/personnel/bloc/personal_state.dart';


class PersonnelBloc extends Bloc<PersonnelEvent, PersonnelState> {
  final PersonnelRepository _repository;

  PersonnelBloc(this._repository) : super(PersonnelInitial()) {
    on<LoadPersonnelList>(_onLoadPersonnelList);
    on<LoadPersonnelDetails>(_onLoadPersonnelDetails);
    on<LoadRoles>(_onLoadRoles);
    on<AddPersonnel>(_onAddPersonnel);
    on<UpdatePersonnel>(_onUpdatePersonnel);
    on<UpdatePersonnelStatus>(_onUpdatePersonnelStatus);
  }

  Future<void> _onLoadPersonnelList(
    LoadPersonnelList event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());

    try {
      final personnelList = await _repository.getPersonnelList(
        userId: event.userId,
      );
      emit(PersonnelListLoaded(
        personnelList,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      emit(PersonnelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadPersonnelDetails(
    LoadPersonnelDetails event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());

    try {
      final personnel = await _repository.getPersonnelDetails(event.id);
      emit(PersonnelDetailsLoaded(personnel));
    } catch (e) {
      emit(PersonnelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadRoles(
    LoadRoles event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());

    try {
      final roles = await _repository.getApiaryRoles();
      emit(RolesLoaded(roles));
    } catch (e) {
      emit(PersonnelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddPersonnel(
    AddPersonnel event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());

    try {
      await _repository.addPersonnel(event.data);
      emit(PersonnelOperationSuccess('Personnel added successfully'));
    } catch (e) {
      emit(PersonnelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdatePersonnel(
    UpdatePersonnel event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());

    try {
      await _repository.updatePersonnel(event.id, event.data);
      emit(PersonnelOperationSuccess('Personnel updated successfully'));
    } catch (e) {
      emit(PersonnelError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdatePersonnelStatus(
    UpdatePersonnelStatus event,
    Emitter<PersonnelState> emit,
  ) async {
    emit(PersonnelLoading());

    try {
      await _repository.updatePersonnelStatus(event.id);
      emit(PersonnelOperationSuccess('Status updated successfully'));
    } catch (e) {
      emit(PersonnelError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}