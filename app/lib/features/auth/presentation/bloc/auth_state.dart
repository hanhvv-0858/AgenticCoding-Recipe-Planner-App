part of 'auth_bloc.dart';

/// States for the Auth BLoC.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before auth check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading during auth operations.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated with a valid user.
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Not authenticated, should show login.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// User chose to continue as guest.
class GuestMode extends AuthState {
  const GuestMode();
}

/// Auth error with a message.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
