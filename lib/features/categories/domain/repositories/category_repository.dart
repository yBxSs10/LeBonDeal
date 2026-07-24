import 'package:lebondeal/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  List<Category> getAllCategories();
}
