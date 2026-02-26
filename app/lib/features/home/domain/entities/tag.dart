import 'package:equatable/equatable.dart';

/// Tag domain entity.
class Tag extends Equatable {
  final String id;
  final String name;
  final String slug;
  final int displayOrder;

  const Tag({
    required this.id,
    required this.name,
    required this.slug,
    this.displayOrder = 0,
  });

  @override
  List<Object?> get props => [id];
}
