import 'package:pocketbase/pocketbase.dart';

import 'api_exceptions.dart';

class ApiClient {
  final PocketBase pocketBase;

  ApiClient({
    required String baseUrl,
    required AsyncAuthStore authStore,
  }) : pocketBase = PocketBase(
          _normalizeBaseUrl(baseUrl),
          authStore: authStore,
        );

  static String _normalizeBaseUrl(String value) {
    var result = value.trim();

    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }

    return result;
  }

  String filter(
    String expression,
    Map<String, dynamic> params,
  ) {
    return pocketBase.filter(expression, params);
  }

  Future<T> run<T>(
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on ClientException catch (error) {
      throw _mapException(error);
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }

      throw NetworkException(
        'Не удалось выполнить запрос к PocketBase: $error',
      );
    }
  }

  ApiException _mapException(
    ClientException error,
  ) {
    final status = error.statusCode;
    final response = error.response;

    final rawMessage = response['message'];
    final message = rawMessage?.toString().trim().isNotEmpty == true
        ? rawMessage.toString()
        : 'Ошибка PocketBase';

    if (status == 0) {
      return const NetworkException(
        'PocketBase недоступен. Проверьте адрес сервера и CORS/HTTPS.',
      );
    }

    if (status == 400 || status == 422) {
      final rawData = response['data'];
      final errors = <String, String>{};

      if (rawData is Map) {
        for (final entry in rawData.entries) {
          final value = entry.value;

          if (value is Map && value['message'] != null) {
            errors[entry.key.toString()] = value['message'].toString();
          } else if (value != null) {
            errors[entry.key.toString()] = value.toString();
          }
        }
      }

      if (errors.isNotEmpty) {
        return ValidationException(
          message,
          errors,
        );
      }

      return BadRequestException(message);
    }

    switch (status) {
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      default:
        if (status >= 500) {
          return ServerException(message);
        }

        return ApiException(message);
    }
  }
}
