import 'package:equatable/equatable.dart';

/// Base failure class for the application.
abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An error occurred'});

  @override
  List<Object?> get props => [message];
}

/// Failure from server/API errors.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    super.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure from local cache errors.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Failure from network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No network connection'});
}
