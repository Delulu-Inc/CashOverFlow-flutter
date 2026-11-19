/// Error thrown by the data layer when a request fails.
///
/// [message] is always safe to show to the user.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;

  /// HTTP status code, or `null` when the request never reached the server
  /// (offline, timeout, CORS, ...).
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isAccessDenied => isUnauthorized || isForbidden;

  @override
  String toString() => message;

  /// Thrown before calling an endpoint that requires a signed-in user when
  /// no session token is stored on the device.
  static const ApiException missingSession = ApiException(
    'Authentication token not found. Please log in again.',
    statusCode: 401,
  );

  /// Extracts a human readable message from a decoded error payload.
  ///
  /// Supports the shapes returned by the API: `{message}`, `{error}`,
  /// `{detail}`, `{title}` and ASP.NET validation `{errors: {field: [..]}}`.
  static String? messageFrom(Object? payload) {
    if (payload is String && payload.trim().isNotEmpty) return payload.trim();
    if (payload is! Map) return null;

    final errors = payload['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final joined = errors.values
          .expand((value) => value is List ? value : [value])
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .join(' ');
      if (joined.isNotEmpty) return joined;
    }

    for (final key in const ['message', 'error', 'detail', 'title', 'reply']) {
      final value = payload[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
