import 'package:lebondeal/features/categories/data/mappers/category_mapper.dart';
import 'package:lebondeal/features/categories/data/models/category.dart'
    as model;
import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/categories/domain/repositories/category_repository.dart';

/// Les catégories sont une liste statique (pas de collection Firestore
/// dédiée) — la "source de données" est donc locale, pas réseau.
class CategoryRepositoryImpl implements CategoryRepository {
  @override
  List<Category> getAllCategories() {
    return CategoryMapper.toEntityList(model.Category.allCategories);
  }
}
