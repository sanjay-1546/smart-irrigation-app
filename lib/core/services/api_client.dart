import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;
  final SecureStorageService _secureStorage;

  ApiClient({http.Client? client, SecureStorageService? secureStorage})
      : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? SecureStorageService();

  Future<Map<String, String>> _headers({bool requiresAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (requiresAuth) {
      final token = await _secureStorage.readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String url, Map<String, dynamic>? query) {
    final uri = Uri.parse(url);
    if (query == null || query.isEmpty) return uri;
    final stringQuery = <String, String>{
      ...uri.queryParameters,
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    return uri.replace(queryParameters: stringQuery);
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .get(_buildUri(url, query), headers: await _headers(requiresAuth: requiresAuth))
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on SocketException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .post(
            _buildUri(url, query),
            headers: await _headers(requiresAuth: requiresAuth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on SocketException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .put(
            _buildUri(url, query),
            headers: await _headers(requiresAuth: requiresAuth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on SocketException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<dynamic> delete(
    String url, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _client
          .delete(
            _buildUri(url, query),
            headers: await _headers(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on SocketException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  /// Decodes the `{success, message, data, errors}` envelope used by the
  /// backend. Returns the `data` payload on success, throws [ApiException]
  /// otherwise.
  dynamic _handleResponse(http.Response response) {
    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) decoded = body;
      } catch (_) {
        // Non-JSON body, fall through to status-code based handling below.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded == null) return null;
      if (decoded.containsKey('success') && decoded['success'] == false) {
        throw ApiException(
          (decoded['message'] as String?) ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      return decoded.containsKey('data') ? decoded['data'] : decoded;
    }

    final message = decoded != null
        ? ((decoded['message'] as String?) ?? 'Request failed with status ${response.statusCode}')
        : 'Request failed with status ${response.statusCode}';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
