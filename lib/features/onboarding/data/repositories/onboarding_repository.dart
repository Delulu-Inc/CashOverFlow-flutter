import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../auth/data/models/set_password_request.dart';
import '../models/demo_request.dart';
import '../models/demo_request_form.dart';

/// Company onboarding: demo requests, approvals and invitation acceptance.
class OnboardingRepository {
  OnboardingRepository({required this._api, required this._storage});

  final ApiClient _api;
  final SessionStorage _storage;

  /// `POST /onboarding/demo-request` (public).
  Future<void> submitDemoRequest(DemoRequestForm form) async {
    final response = await _api.post(
      '/onboarding/demo-request',
      body: form.toJson(),
      authenticated: false,
      timeout: const Duration(seconds: 15),
    );
    if (response.statusCode == 200 || response.statusCode == 201) return;

    // Also surfaces ASP.NET validation errors of CreateDemoRequestDto.
    throw response.toException('Registration failed. Please try again.');
  }

  /// `GET /onboarding/demo-requests` (admin).
  Future<List<DemoRequest>> fetchDemoRequests() async {
    final response = await _api.get('/onboarding/demo-requests');

    if (response.statusCode == 200) {
      final data = response.data;
      final Object? list = data is List
          ? data
          : (data is Map ? (data['data'] ?? data['items']) : null);

      return (list is List ? list : const [])
          .whereType<Map<String, dynamic>>()
          .map(DemoRequest.fromJson)
          .toList();
    }

    throw response.toException(
      'Failed to load demo requests (${response.statusCode})',
    );
  }

  /// `POST /onboarding/approve/{id}` (admin) – sends the invitation e-mail.
  Future<bool> approveDemoRequest(String id) async {
    if (id.isEmpty) return false;
    try {
      final response = await _api.post('/onboarding/approve/$id');
      return response.isSuccess;
    } on ApiException {
      return false;
    }
  }

  /// `POST /onboarding/accept-invite` – the company owner sets a password.
  Future<void> acceptInvite(SetPasswordRequest request) async {
    final response = await _api.post(
      '/onboarding/accept-invite',
      body: request.toOnboardingJson(),
      authenticated: false,
    );
    if (response.statusCode == 200 || response.statusCode == 201) return;

    throw response.toException(
      'Failed to complete onboarding (${response.statusCode})',
    );
  }

  /// Remembers the invitation token across the Stripe redirect so that
  /// "Try again" and "Continue → Set password" still know the invitation.
  Future<void> rememberInviteToken(String token) =>
      _storage.savePendingInviteToken(token);

  Future<String?> get pendingInviteToken => _storage.readPendingInviteToken();

  Future<void> clearPendingInviteToken() => _storage.clearPendingInviteToken();
}
