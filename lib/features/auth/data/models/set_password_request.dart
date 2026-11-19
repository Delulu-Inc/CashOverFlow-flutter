/// Payload used to accept an invitation by choosing a password.
class SetPasswordRequest {
  const SetPasswordRequest({
    required this.token,
    required this.password,
    required this.confirmPassword,
    this.firstName = 'Team',
    this.lastName = 'Member',
  });

  final String token;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;

  /// Body of `POST /onboarding/accept-invite` (company owner).
  Map<String, dynamic> toOnboardingJson() {
    return {
      'token': token,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  /// Body of `POST /team/accept-invite` (invited team member).
  Map<String, dynamic> toTeamJson() {
    return {
      'token': token,
      'password': password,
      'confirmPassword': confirmPassword,
      'firstName': firstName.isNotEmpty ? firstName : 'Team',
      'lastName': lastName.isNotEmpty ? lastName : 'Member',
    };
  }
}
