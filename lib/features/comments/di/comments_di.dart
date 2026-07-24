import 'package:get_it/get_it.dart';

import 'package:lebondeal/features/comments/data/repositories/comment_repository_impl.dart';
import 'package:lebondeal/features/comments/domain/repositories/comment_repository.dart';
import 'package:lebondeal/features/deals/data/datasources/remote/firestore_service.dart';

/// Configure les dépendances liées aux commentaires
void configureCommentsDependencies() {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<CommentRepository>()) {
    getIt.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(getIt<FirestoreService>()),
    );
  }
}
