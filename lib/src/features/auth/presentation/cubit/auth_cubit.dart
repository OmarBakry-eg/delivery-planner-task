import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/get_auth_status.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/login.dart';
import 'package:test_hsa_group/src/features/auth/domain/usecases/logout.dart';
import 'package:test_hsa_group/src/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetAuthStatusUseCase getStatus;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.getStatus,
    required this.loginUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthOnStart() async {
    emit(AuthLoading());
    try {
      final (authed, user) = await getStatus();
      if (authed && user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  // UI bits: store ephemeral login view state here instead of setState
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    // Re-emit current state to rebuild listeners
    final current = state;
    emit(current);
  }

  Future<void> signOut() async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}
