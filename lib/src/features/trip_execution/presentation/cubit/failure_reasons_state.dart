import 'package:equatable/equatable.dart';

class FailureReasonsState extends Equatable {
  final List<String> reasons;

  const FailureReasonsState({this.reasons = const []});

  FailureReasonsState copyWith({List<String>? reasons}) =>
      FailureReasonsState(reasons: reasons ?? this.reasons);

  @override
  List<Object?> get props => [reasons];
}
