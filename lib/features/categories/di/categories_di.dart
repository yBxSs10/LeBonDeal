import 'package:get_it/get_it.dart';

import 'package:lebondeal/features/categories/data/repositories/category_repository_impl.dart';
import 'package:lebondeal/features/categories/domain/repositories/category_repository.dart';

/// Configure les dépendances liées aux catégories
void configureCategoriesDependencies() {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(),
    );
  }
}
