import 'package:equatable/equatable.dart';
import 'package:test_hsa_group/src/features/auth/domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthObscurePassword extends AuthState {
  final bool obscurePassword;
  const AuthObscurePassword(this.obscurePassword);

  @override
  List<Object?> get props => [obscurePassword];
}

class ToggledAuthObscurePassword extends AuthState {
  final bool obscurePassword;
  const ToggledAuthObscurePassword(this.obscurePassword);

  @override
  List<Object?> get props => [obscurePassword];
}
class AuthUnauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
