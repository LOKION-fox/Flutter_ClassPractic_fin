import '../core/api_client.dart';
import '../core/api_exceptions.dart';
import '../core/auth_service.dart';
import '../models/customer.dart';
import '../models/page_result.dart';
import '../models/simple_query.dart';
import 'customer_repository.dart';

class ApiCustomerRepository implements CustomerRepository {
  final ApiClient _api;
  final AuthService _auth;

  ApiCustomerRepository(this._api, this._auth);

  Map<String, dynamic> _withCard(Map<String, dynamic> json) {
    final expand = json['expand'];

    if (expand is Map) {
      final raw = expand['loyalty_cards_via_customerId'];

      if (raw is Map) {
        json['loyaltyCard'] = Map<String, dynamic>.from(raw);
      } else if (raw is List && raw.isNotEmpty && raw.first is Map) {
        json['loyaltyCard'] = Map<String, dynamic>.from(raw.first as Map);
      }
    }

    json.putIfAbsent('loyaltyCard', () => <String, dynamic>{});
    return json;
  }

  String? _filter(SimpleQuery query) {
    final parts = <String>[];
    final params = <String, dynamic>{};

    if (!query.includeDeleted) parts.add('deletedAt = ""');

    if (query.search.trim().isNotEmpty) {
      parts.add('('
          'firstName ~ {:search} || '
          'lastName ~ {:search} || '
          'email ~ {:search} || '
          'phone ~ {:search} || '
          'loyalty_cards_via_customerId.number ?~ {:search}'
          ')');
      params['search'] = query.search.trim();
    }

    if (query.filter != null) {
      parts.add('loyalty_cards_via_customerId.level ?= {:level}');
      params['level'] = query.filter;
    }

    if (parts.isEmpty) return null;
    return _api.filter(parts.join(' && '), params);
  }

  String _sort(SimpleQuery query) {
    final field = query.sortField == 'points'
        ? 'loyalty_cards_via_customerId.points'
        : query.sortField;
    return query.sortAscending ? field : '-$field';
  }

  @override
  Future<PageResult<Customer>> find(SimpleQuery query) {
    return _api.run(() async {
      final result = await _api.pocketBase.collection('customers').getList(
            page: query.page,
            perPage: query.size,
            filter: _filter(query),
            sort: _sort(query),
            expand: 'loyalty_cards_via_customerId',
          );

      return PageResult<Customer>(
        items: result.items
            .map((record) => Customer.fromJson(_withCard(record.toJson())))
            .toList(),
        page: result.page,
        size: result.perPage,
        total: result.totalItems,
      );
    });
  }

  @override
  Future<List<Customer>> all() {
    return _api.run(() async {
      final records = await _api.pocketBase.collection('customers').getFullList(
            sort: 'lastName,firstName',
            expand: 'loyalty_cards_via_customerId',
          );

      return records
          .map((record) => Customer.fromJson(_withCard(record.toJson())))
          .toList();
    });
  }

  @override
  Future<Customer?> findById(String id) async {
    try {
      return await _api.run(() async {
        final record = await _api.pocketBase.collection('customers').getOne(
              id,
              expand: 'loyalty_cards_via_customerId',
            );
        return Customer.fromJson(_withCard(record.toJson()));
      });
    } on NotFoundException {
      return null;
    }
  }

  Future<void> _ensureCardNumberAvailable(
    String number, {
    String? exceptCardId,
  }) async {
    final filter = _api.filter('number = {:number}', {'number': number});
    final records = await _api.pocketBase.collection('loyalty_cards').getFullList(
          filter: filter,
        );

    final duplicate = records.any((record) => record.id != exceptCardId);

    if (duplicate) {
      throw const ValidationException(
        'Ошибка валидации',
        {'number': 'Карта с таким номером уже существует'},
      );
    }
  }

  @override
  Future<Customer> create(Customer customer) {
    return _auth.authorized(() => _api.run(() async {
          await _ensureCardNumberAvailable(customer.loyaltyCard.number);

          final customerRecord = await _api.pocketBase.collection('customers').create(
                body: customer.toJson(),
              );

          try {
            await _api.pocketBase.collection('loyalty_cards').create(
              body: {
                'customerId': customerRecord.id,
                ...customer.loyaltyCard.toJson(),
              },
            );
          } catch (_) {
            // Менеджер не может физически удалить запись по правилам PocketBase,
            // поэтому помечаем незавершённую запись как удалённую.
            await _api.pocketBase.collection('customers').update(
              customerRecord.id,
              body: {'deletedAt': DateTime.now().toUtc().toIso8601String()},
            );
            rethrow;
          }

          final created = await _api.pocketBase.collection('customers').getOne(
                customerRecord.id,
                expand: 'loyalty_cards_via_customerId',
              );

          return Customer.fromJson(_withCard(created.toJson()));
        }));
  }

  @override
  Future<void> update(Customer customer) {
    return _auth.authorized(() => _api.run(() async {
          final cardId = customer.loyaltyCard.id;
          await _ensureCardNumberAvailable(
            customer.loyaltyCard.number,
            exceptCardId: cardId.isEmpty ? null : cardId,
          );

          await _api.pocketBase.collection('customers').update(
                customer.id,
                body: customer.toJson(),
              );

          if (cardId.isNotEmpty) {
            await _api.pocketBase.collection('loyalty_cards').update(
                  cardId,
                  body: customer.loyaltyCard.toJson(),
                );
          } else {
            final existing = await _api.pocketBase.collection('loyalty_cards').getFullList(
                  filter: _api.filter(
                    'customerId = {:customerId}',
                    {'customerId': customer.id},
                  ),
                );

            if (existing.isEmpty) {
              await _api.pocketBase.collection('loyalty_cards').create(
                body: {
                  'customerId': customer.id,
                  ...customer.loyaltyCard.toJson(),
                },
              );
            } else {
              await _api.pocketBase.collection('loyalty_cards').update(
                    existing.first.id,
                    body: customer.loyaltyCard.toJson(),
                  );
            }
          }
        }));
  }

  Future<void> _setCardDeletedAt(String customerId, String value) async {
    final cards = await _api.pocketBase.collection('loyalty_cards').getFullList(
          filter: _api.filter(
            'customerId = {:customerId}',
            {'customerId': customerId},
          ),
        );

    for (final card in cards) {
      await _api.pocketBase.collection('loyalty_cards').update(
        card.id,
        body: {'deletedAt': value},
      );
    }
  }

  @override
  Future<void> softDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          final date = DateTime.now().toUtc().toIso8601String();
          await _api.pocketBase.collection('customers').update(
            id,
            body: {'deletedAt': date},
          );
          await _setCardDeletedAt(id, date);
        }));
  }

  @override
  Future<void> hardDelete(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('customers').delete(id);
        }));
  }

  @override
  Future<void> restore(String id) {
    return _auth.authorized(() => _api.run(() async {
          await _api.pocketBase.collection('customers').update(id, body: {'deletedAt': ''});
          await _setCardDeletedAt(id, '');
        }));
  }

  @override
  Future<int> deleteMany(List<String> ids) {
    return _auth.authorized(() => _api.run(() async {
          var count = 0;
          for (final id in ids) {
            final date = DateTime.now().toUtc().toIso8601String();
            await _api.pocketBase.collection('customers').update(
              id,
              body: {'deletedAt': date},
            );
            await _setCardDeletedAt(id, date);
            count++;
          }
          return count;
        }));
  }
}
