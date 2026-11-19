import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../auth/data/models/set_password_request.dart';
import '../models/team_member.dart';

/// Organization members & invitations.
class TeamRepository {
  TeamRepository({required this._api, required this._storage});

  final ApiClient _api;
  final SessionStorage _storage;

  /// `GET /team/members`
  ///
  /// Throws an [ApiException] with `isAccessDenied` for 401/403 so the UI
  /// can send non-owners back to the dashboard.
  Future<List<TeamMember>> fetchMembers() async {
    if (!await _storage.hasToken) throw ApiException.missingSession;

    final response = await _api.get('/team/members');

    if (response.statusCode == 200) {
      final data = response.data;
      final Object? list = data is List
          ? data
          : (data is Map
                ? (data['data'] ?? data['members'] ?? data['items'])
                : null);

      return (list is List ? list : const [])
          .whereType<Map<String, dynamic>>()
          .map(TeamMember.fromJson)
          .toList();
    }

    throw response.toException(
      'Failed to load team members (${response.statusCode})',
    );
  }

  /// `POST /team/invite`
  Future<void> inviteMember({
    required String email,
    required String role,
  }) async {
    if (!await _storage.hasToken) throw ApiException.missingSession;

    final response = await _api.post(
      '/team/invite',
      body: {'email': email, 'role': role},
    );
    if (response.statusCode == 200 || response.statusCode == 201) return;

    throw response.toException(
      'Failed to send the invitation (${response.statusCode})',
    );
  }

  /// `DELETE /team/member/{id}` – revokes a member's access.
  Future<void> removeMember(String id) async {
    if (!await _storage.hasToken) throw ApiException.missingSession;
    if (id.isEmpty) {
      throw const ApiException('This member cannot be removed.');
    }

    final response = await _api.delete(
      '/team/member/${Uri.encodeComponent(id)}',
    );
    if (response.isSuccess) return;

    throw response.toException(
      'Failed to remove access (${response.statusCode})',
    );
  }

  /// `POST /team/accept-invite` – an invited member sets a password.
  Future<void> acceptInvite(SetPasswordRequest request) async {
    final response = await _api.post(
      '/team/accept-invite',
      body: request.toTeamJson(),
      authenticated: false,
    );
    if (response.statusCode == 200 || response.statusCode == 201) return;

    throw response.toException(
      'Failed to accept team invite (${response.statusCode})',
    );
  }
}
