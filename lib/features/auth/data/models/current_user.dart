/// The signed-in user as returned by `GET /me`.
class CurrentUser {
  const CurrentUser({
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.jobTitle,
    this.companyId,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String? jobTitle;
  final String? companyId;

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    String? read(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return null;
    }

    return CurrentUser(
      firstName: read(const ['firstName', 'FirstName']),
      lastName: read(const ['lastName', 'LastName']),
      email: read(const ['email', 'Email']),
      role: read(const ['role', 'Role']),
      jobTitle: read(const ['jobTitle', 'JobTitle']),
      companyId: read(const ['companyId', 'organizationId', 'CompanyId']),
    );
  }

  /// Role shown in the UI and used for permissions.
  String get displayRole => role ?? jobTitle ?? 'Member';

  bool get isOwner => displayRole.trim().toLowerCase() == 'owner';

  bool get isAdmin => role?.trim().toLowerCase() == 'admin';
}
