import '../models/animal.dart';
import '../models/animal_query.dart';
import '../models/page_result.dart';

abstract interface class AnimalRepository {
  Future<PageResult<Animal>> find(AnimalQuery query);
  Future<List<Animal>> all();
  Future<Animal?> findById(String id);
  Future<Animal> create(Animal animal);
  Future<void> update(Animal animal);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<void> restore(String id);
  Future<int> deleteMany(List<String> ids);
}
