import 'package:dartz/dartz.dart';
import 'package:lebondeal/features/comments/data/models/comment.dart' as model;
import 'package:lebondeal/features/comments/domain/entities/comment_entity.dart';
import 'package:lebondeal/features/comments/domain/repositories/comment_repository.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';

class CommentRepositoryImpl implements CommentRepository {
  final FirestoreService _firestoreService;

  CommentRepositoryImpl(this._firestoreService);

  @override
  Stream<List<CommentEntity>> getCommentsStream(String dealId) {
    return _firestoreService
        .getCommentsStream(dealId)
        .map((comments) => comments.map(_toEntity).toList());
  }

  @override
  Future<Either<String, Unit>> addComment({
    required String dealId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    try {
      final comment = model.Comment(
        id: '',
        dealId: dealId,
        author: authorName,
        content: content,
        createdAt: DateTime.now(),
      );
      await _firestoreService.addComment(comment, authorId);
      return const Right(unit);
    } catch (_) {
      return const Left('Erreur lors de l\'envoi du commentaire');
    }
  }

  CommentEntity _toEntity(model.Comment comment) => CommentEntity(
    id: comment.id,
    dealId: comment.dealId,
    author: comment.author,
    content: comment.content,
    createdAt: comment.createdAt,
  );
}
