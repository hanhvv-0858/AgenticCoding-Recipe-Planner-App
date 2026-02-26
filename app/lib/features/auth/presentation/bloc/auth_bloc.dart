import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/auth/domain/entities/user.dart';
import 'package:recipe_planner/features/auth/domain/usecases/get_current_user.dart';
import 'package:recipe_planner/features/auth/domain/usecases/login.dart';
import 'package:recipe_planner/features/auth/domain/usecases/logout.dart';
import 'package:recipe_planner/features/auth/domain/usecases/register.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for the Auth feature.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final Login login;
  final Register register;
  final Logout logout;

  AuthBloc({
    required this.getCurrentUser,
    required this.login,
    required this.register,
    required this.logout,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<ContinueAsGuest>(_onContinueAsGuest);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUser(const NoParams());

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await login(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await register(RegisterParams(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    ));

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logout(const NoParams());
    emit(const Unauthenticated());
  }

  void _onContinueAsGuest(
    ContinueAsGuest event,
    Emitter<AuthState> emit,
  ) {
    emit(const GuestMode());
  }
}
