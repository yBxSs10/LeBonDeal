import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/comments/domain/entities/comment_entity.dart';

abstract class CommentRepository {
  Stream<List<CommentEntity>> getCommentsStream(String dealId);

  Future<Either<String, Unit>> addComment({
    required String dealId,
    required String authorId,
    required String authorName,
    required String content,
  });
}
