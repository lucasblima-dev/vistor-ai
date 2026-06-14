import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/features/auth/data/user_repository.dart';
import 'package:vistor_ai_mobile/features/auth/domain/user_management_state.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final UserRepository _userRepository;

  UserManagementCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserManagementState.initial());

  Future<void> loadUsers() async {
    emit(const UserManagementState.loading());
    try {
      final users = await _userRepository.getAll();
      emit(UserManagementState.loaded(users: users));
    } catch (e) {
      emit(UserManagementState.error(e.toString()));
    }
  }

  void search(String query) {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return;
    emit(currentState.copyWith(searchQuery: query));
  }

  Future<bool> updateRole(String userId, UserRole role) async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return false;

    emit(currentState.copyWith(isUpdating: true, error: null));
    try {
      await _userRepository.updateRole(userId, role);
      final updatedUsers = await _userRepository.getAll();
      emit(currentState.copyWith(users: updatedUsers, isUpdating: false));
      return true;
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> toggleActive(String userId, bool isActive) async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return false;

    emit(currentState.copyWith(isUpdating: true, error: null));
    try {
      await _userRepository.toggleActive(userId, isActive);
      final updatedUsers = await _userRepository.getAll();
      emit(currentState.copyWith(users: updatedUsers, isUpdating: false));
      return true;
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return false;

    emit(currentState.copyWith(isUpdating: true, error: null));
    try {
      await _userRepository.create(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      final updatedUsers = await _userRepository.getAll();
      emit(currentState.copyWith(users: updatedUsers, isUpdating: false));
      return true;
    } catch (e) {
      emit(currentState.copyWith(
        isUpdating: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }
}
