/// A user with access to the organization dashboard.
class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
  });

  final String id;
  final String name;
  final String email;
  final String position;

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'N/A',
      email: json['email']?.toString() ?? 'N/A',
      position:
          json['position']?.toString() ?? json['role']?.toString() ?? 'N/A',
    );
  }
}

/// Positions an owner can invite (value sent to the API → label).
abstract final class TeamRoles {
  static const Map<String, String> invitable = {
    'FinanceManager': 'Finance Manager',
    'Owner': 'Owner',
  };
}
