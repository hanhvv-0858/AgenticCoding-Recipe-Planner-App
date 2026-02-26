/// Base exception classes for the application.

/// Thrown when a server request fails.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Server error occurred',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Thrown when a local cache operation fails.
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when there is no network connectivity.
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No network connection'});

  @override
  String toString() => 'NetworkException(message: $message)';
}
