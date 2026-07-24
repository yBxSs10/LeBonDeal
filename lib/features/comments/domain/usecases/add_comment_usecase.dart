import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/comments/domain/repositories/comment_repository.dart';

class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<String, Unit>> call({
    required String dealId,
    required String authorId,
    required String authorName,
    required String content,
  }) => repository.addComment(
    dealId: dealId,
    authorId: authorId,
    authorName: authorName,
    content: content,
  );
}
