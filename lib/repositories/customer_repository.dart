import '../models/customer.dart';
import '../models/page_result.dart';
import '../models/simple_query.dart';

abstract interface class CustomerRepository {
  Future<PageResult<Customer>> find(SimpleQuery query);
  Future<List<Customer>> all();
  Future<Customer?> findById(String id);
  Future<Customer> create(Customer customer);
  Future<void> update(Customer customer);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<void> restore(String id);
  Future<int> deleteMany(List<String> ids);
}
