import 'package:lebondeal/features/comments/domain/entities/comment_entity.dart';
import 'package:lebondeal/features/comments/domain/repositories/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Stream<List<CommentEntity>> call(String dealId) =>
      repository.getCommentsStream(dealId);
}
