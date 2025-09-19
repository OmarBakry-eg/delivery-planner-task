import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/trip_execution/presentation/cubit/failure_reasons_state.dart';

class FailureReasonsCubit extends Cubit<FailureReasonsState> {
  FailureReasonsCubit() : super(const FailureReasonsState());

  void addReason(String reason) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) return;
    if (state.reasons.contains(trimmed)) return;
    emit(state.copyWith(reasons: [...state.reasons, trimmed]));
  }

  void removeReason(String reason) {
    emit(
      state.copyWith(reasons: state.reasons.where((r) => r != reason).toList()),
    );
  }

  void clear() {
    emit(const FailureReasonsState(reasons: []));
  }
}
