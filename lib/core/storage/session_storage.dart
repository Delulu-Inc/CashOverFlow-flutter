import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user session on the device.
///
/// The storage keys are kept identical to the ones the app used before the
/// refactor so existing sessions keep working after an update.
class SessionStorage {
  static const String _tokenKey = 'auth_token';
  static const String _legacyTokenKey = 'token';
  static const String _emailKey = 'user_email';
  static const String _roleKey = 'user_role';
  static const String _pendingInviteTokenKey = 'pending_invite_token';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> readToken() async {
    final prefs = await _prefs;
    final token =
        prefs.getString(_tokenKey) ?? prefs.getString(_legacyTokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  Future<bool> get hasToken async => (await readToken()) != null;

  Future<void> saveSession({
    required String token,
    required String email,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
  }

  Future<String?> readRole() async => (await _prefs).getString(_roleKey);

  Future<void> saveRole(String role) async {
    await (await _prefs).setString(_roleKey, role);
  }

  /// Invitation token received from the "accept invite" e-mail link.
  ///
  /// It is kept across the Stripe redirect so that "Try again" (payment
  /// failed) and "Continue" (payment succeeded → set password) still know
  /// which invitation they belong to.
  Future<String?> readPendingInviteToken() async {
    final token = (await _prefs).getString(_pendingInviteTokenKey);
    return (token == null || token.isEmpty) ? null : token;
  }

  Future<void> savePendingInviteToken(String token) async {
    await (await _prefs).setString(_pendingInviteTokenKey, token);
  }

  Future<void> clearPendingInviteToken() async {
    await (await _prefs).remove(_pendingInviteTokenKey);
  }

  /// Signs the user out by wiping everything stored on the device.
  Future<void> clear() async {
    await (await _prefs).clear();
  }
}
