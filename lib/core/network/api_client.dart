import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../storage/session_storage.dart';
import '../utils/app_logger.dart';
import 'api_exception.dart';

/// Raw result of an API call.
class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body, this.data});

  final int statusCode;
  final String body;

  /// Decoded JSON body (`Map`, `List`, `String`, `num`, ...), or `null` when
  /// the body is empty or not valid JSON.
  final Object? data;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic>? get json =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : null;

  /// Builds an [ApiException] carrying the best available server message.
  ApiException toException(String fallbackMessage) {
    return ApiException(
      ApiException.messageFrom(data) ?? _plainTextBody ?? fallbackMessage,
      statusCode: statusCode,
    );
  }

  /// Short plain-text bodies (not HTML error pages) are shown as-is.
  String? get _plainTextBody {
    final text = body.trim();
    if (data != null || text.isEmpty || text.length > 200) return null;
    if (text.startsWith('<')) return null;
    return text;
  }
}

/// Single entry point for every HTTP call made by the app.
///
/// Responsibilities:
/// * builds URLs from [AppConfig.apiBaseUrl],
/// * sends JSON headers and the bearer token when [authenticated] is true,
/// * applies a timeout so the UI never hangs forever,
/// * converts transport failures into user friendly [ApiException]s.
class ApiClient {
  ApiClient({
    required this._storage,
    http.Client? httpClient,
    this._baseUrl = AppConfig.apiBaseUrl,
    this._timeout = AppConfig.requestTimeout,
  }) : _http = httpClient ?? http.Client();

  final SessionStorage _storage;
  final http.Client _http;
  final String _baseUrl;
  final Duration _timeout;

  Future<ApiResponse> get(
    String path, {
    Map<String, Object?>? query,
    bool authenticated = true,
    Duration? timeout,
  }) {
    return _send(
      'GET',
      path,
      query: query,
      authenticated: authenticated,
      timeout: timeout,
    );
  }

  Future<ApiResponse> post(
    String path, {
    Object? body,
    bool authenticated = true,
    Duration? timeout,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      authenticated: authenticated,
      timeout: timeout,
    );
  }

  Future<ApiResponse> put(
    String path, {
    Object? body,
    bool authenticated = true,
    Duration? timeout,
  }) {
    return _send(
      'PUT',
      path,
      body: body,
      authenticated: authenticated,
      timeout: timeout,
    );
  }

  Future<ApiResponse> delete(
    String path, {
    bool authenticated = true,
    Duration? timeout,
  }) {
    return _send(
      'DELETE',
      path,
      authenticated: authenticated,
      timeout: timeout,
    );
  }

  Uri _buildUri(String path, Map<String, Object?>? query) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        for (final entry in query.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      },
    );
  }

  Future<Map<String, String>> _headers(bool authenticated) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authenticated) {
      final token = await _storage.readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponse> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    required bool authenticated,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _headers(authenticated);
    final encodedBody = body == null ? null : jsonEncode(body);

    try {
      final Future<http.Response> request = switch (method) {
        'POST' => _http.post(uri, headers: headers, body: encodedBody),
        'PUT' => _http.put(uri, headers: headers, body: encodedBody),
        'DELETE' => _http.delete(uri, headers: headers),
        _ => _http.get(uri, headers: headers),
      };

      final response = await request.timeout(timeout ?? _timeout);
      AppLogger.debug('$method $uri → ${response.statusCode}');

      return ApiResponse(
        statusCode: response.statusCode,
        body: response.body,
        data: _tryDecode(response.body),
      );
    } on TimeoutException {
      AppLogger.error('$method $uri timed out');
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on ApiException {
      rethrow;
    } catch (error) {
      AppLogger.error('$method $uri failed', error);
      throw const ApiException(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  static Object? _tryDecode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }
}
