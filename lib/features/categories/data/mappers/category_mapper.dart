import '../models/category.dart' as model;
import '../../domain/entities/category.dart' as entity;

class CategoryMapper {
  static entity.Category toEntity(model.Category model) {
    return entity.Category(
      id: model.id,
      name: model.name,
      icon: model.icon,
      color: model.color,
    );
  }

  static model.Category toModel(entity.Category entity) {
    return model.Category(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
    );
  }

  static List<entity.Category> toEntityList(List<model.Category> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<model.Category> toModelList(List<entity.Category> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
