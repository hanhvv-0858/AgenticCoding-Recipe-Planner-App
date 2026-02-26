import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';

/// Base use case class following Clean Architecture.
///
/// [Type] is the return type on success.
/// [Params] is the parameter type.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when the use case takes no parameters.
class NoParams {
  const NoParams();
}
