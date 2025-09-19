import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int selectedIndex;

  const HomeState({this.selectedIndex = 0});

  HomeState copyWith({int? selectedIndex}) =>
      HomeState(selectedIndex: selectedIndex ?? this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}
