import '../models/page_result.dart';
import '../models/simple_query.dart';
import '../models/supplier.dart';

abstract interface class SupplierRepository {
  Future<PageResult<Supplier>> find(SimpleQuery query);
  Future<List<Supplier>> all();
  Future<Supplier?> findById(String id);
  Future<Supplier> create(Supplier supplier);
  Future<void> update(Supplier supplier);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<void> restore(String id);
  Future<int> deleteMany(List<String> ids);
}
