part of 'auth_bloc.dart';

/// Events for the Auth BLoC.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status.
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Submit login credentials.
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Submit registration data.
class RegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const RegisterSubmitted({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Request logout.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Continue using the app as a guest.
class ContinueAsGuest extends AuthEvent {
  const ContinueAsGuest();
}
