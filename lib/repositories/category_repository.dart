import '../models/category.dart';
import '../models/page_result.dart';
import '../models/simple_query.dart';

abstract interface class CategoryRepository {
  Future<PageResult<Category>> find(SimpleQuery query);
  Future<List<Category>> all();
  Future<Category?> findById(String id);
  Future<Category> create(Category category);
  Future<void> update(Category category);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<void> restore(String id);
  Future<int> deleteMany(List<String> ids);
}
