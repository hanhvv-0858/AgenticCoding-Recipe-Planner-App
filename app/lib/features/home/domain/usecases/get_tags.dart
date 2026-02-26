import 'package:dartz/dartz.dart';
import 'package:recipe_planner/core/error/failures.dart';
import 'package:recipe_planner/core/usecases/usecase.dart';
import 'package:recipe_planner/features/home/domain/entities/tag.dart';
import 'package:recipe_planner/features/home/domain/repositories/home_repository.dart';

/// Get all available tags.
class GetTags extends UseCase<List<Tag>, NoParams> {
  final HomeRepository repository;

  GetTags(this.repository);

  @override
  Future<Either<Failure, List<Tag>>> call(NoParams params) {
    return repository.getTags();
  }
}
