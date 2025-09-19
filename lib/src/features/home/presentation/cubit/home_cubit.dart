import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/home/presentation/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void setSelectedIndex(int index) =>
      emit(state.copyWith(selectedIndex: index));
}
