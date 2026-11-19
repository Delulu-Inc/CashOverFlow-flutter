import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../models/current_user.dart';

class LoginResult {
  const LoginResult({required this.token, required this.message});

  final String token;
  final String message;
}

/// Authentication & current-user endpoints.
class AuthRepository {
  AuthRepository({required this._api, required this._storage});

  final ApiClient _api;
  final SessionStorage _storage;

  Future<bool> get hasSession => _storage.hasToken;

  Future<String?> get cachedRole => _storage.readRole();

  /// `POST /login` – stores the session token on success.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      '/login',
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    final json = response.json ?? const <String, dynamic>{};

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = json['token']?.toString() ?? '';
      if (token.isEmpty) {
        throw const ApiException(
          'Login succeeded but no authentication token was returned.',
        );
      }
      await _storage.saveSession(token: token, email: email);
      return LoginResult(
        token: token,
        message: json['message']?.toString() ?? 'User logged in successfully',
      );
    }

    throw ApiException(
      json['message']?.toString() ??
          json['error']?.toString() ??
          'Login failed. Please check your credentials.',
      statusCode: response.statusCode,
    );
  }

  /// `GET /me` – also caches the role used by the route guards.
  Future<CurrentUser> fetchCurrentUser() async {
    final response = await _api.get('/me');
    final json = response.json;

    if (response.statusCode == 200 && json != null) {
      final user = CurrentUser.fromJson(json);
      await _storage.saveRole(user.displayRole);
      return user;
    }

    throw response.toException(
      'Failed to load profile data (${response.statusCode})',
    );
  }

  /// `POST /logout` – invalidates the session on the server, then always
  /// clears the device (even when offline).
  Future<void> logout() async {
    try {
      if (await _storage.hasToken) {
        await _api.post('/logout', timeout: const Duration(seconds: 5));
      }
    } on ApiException {
      // Signing out locally must never fail.
    } finally {
      await _storage.clear();
    }
  }
}
