import 'package:lebondeal/features/categories/domain/entities/category.dart';
import 'package:lebondeal/features/categories/domain/repositories/category_repository.dart';

class GetAllCategoriesUseCase {
  final CategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  List<Category> call() => repository.getAllCategories();
}
