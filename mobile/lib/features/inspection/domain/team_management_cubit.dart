import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vistor_ai_mobile/features/inspection/data/inspection_repository.dart';
import 'package:vistor_ai_mobile/features/auth/data/user_repository.dart';
import 'package:vistor_ai_mobile/features/inspection/domain/team_management_state.dart';
import 'package:vistor_ai_mobile/shared/models/inspection.dart';
import 'package:vistor_ai_mobile/shared/models/user.dart';

class TeamManagementCubit extends Cubit<TeamManagementState> {
  final InspectionRepository _inspectionRepository;
  final UserRepository _userRepository;

  TeamManagementCubit({
    required InspectionRepository inspectionRepository,
    required UserRepository userRepository,
  })  : _inspectionRepository = inspectionRepository,
        _userRepository = userRepository,
        super(const TeamManagementState.initial());

  Future<void> loadQueue() async {
    emit(const TeamManagementState.loading());
    try {
      final unassigned = await _inspectionRepository.getAll(status: 'open');
      final activeInspectors = await _userRepository.getAll(
        role: UserRole.inspector,
        isActive: true,
      );
      emit(TeamManagementState.loaded(
        unassignedInspections: unassigned,
        activeInspectors: activeInspectors,
      ));
    } catch (e) {
      emit(TeamManagementState.error(e.toString()));
    }
  }

  Future<bool> assignInspector(String inspectionId, String inspectorId) async {
    final currentState = state.maybeMap(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (currentState == null) return false;

    emit(currentState.copyWith(isAssigning: true, error: null));
    try {
      await _inspectionRepository.update(
        inspectionId,
        InspectionUpdate(
          status: InspectionStatus.inProgress,
          assignedTo: inspectorId,
        ),
      );
      await loadQueue();
      return true;
    } catch (e) {
      emit(currentState.copyWith(
        isAssigning: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }
}
