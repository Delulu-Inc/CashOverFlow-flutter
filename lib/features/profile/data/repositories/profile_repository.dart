import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';

/// Updates the signed-in user's profile and password.
class ProfileRepository {
  ProfileRepository({required this._api, required this._storage});

  final ApiClient _api;
  final SessionStorage _storage;

  static const ApiException _sessionExpired = ApiException(
    'Session expired. Please log in again.',
    statusCode: 401,
  );

  /// `PUT /profile`
  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String avatarUrl,
  }) async {
    if (!await _storage.hasToken) throw _sessionExpired;

    final response = await _api.put(
      '/profile',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'avatarUrl': avatarUrl,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw ApiException(
      'Failed to update profile (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  /// `POST /profile/change-password`
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await _storage.hasToken) throw _sessionExpired;

    final response = await _api.post(
      '/profile/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw ApiException(
      ApiException.messageFrom(response.data) ??
          'Failed to change password. Please check your inputs.',
      statusCode: response.statusCode,
    );
  }
}
