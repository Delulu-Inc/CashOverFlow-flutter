import '../../../../core/utils/formatters.dart';

/// A company asking for a demo (admin dashboard).
class DemoRequest {
  DemoRequest({
    required this.id,
    required this.companyName,
    required this.contactEmail,
    required this.phoneNumber,
    required this.submissionDate,
    required this.status,
  });

  final String id;
  final String companyName;
  final String contactEmail;
  final String phoneNumber;

  /// `yyyy-MM-dd`, or the raw value when it cannot be parsed.
  final String submissionDate;

  /// `Pending`, `Contacted` or `Closed`.
  String status;

  DateTime? get submittedAt => DateTime.tryParse(submissionDate);

  factory DemoRequest.fromJson(Map<String, dynamic> json) {
    String read(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    final rawDate = read(const [
      'submittedAt',
      'submissionDate',
      'submission_date',
      'createdAt',
      'SubmissionDate',
      'created_at',
      'submitted_at',
    ]);
    final parsedDate = DateTime.tryParse(rawDate);

    return DemoRequest(
      id: read(const ['id', 'Id', 'demoRequestId', 'requestId']),
      companyName: read(const [
        'companyName',
        'company_name',
        'CompanyName',
        'company',
      ]),
      contactEmail: read(const [
        'companyEmail',
        'contactEmail',
        'email',
        'contact_email',
        'ContactEmail',
        'company_email',
      ]),
      phoneNumber: read(const [
        'phoneNumber',
        'phone_number',
        'phone',
        'PhoneNumber',
      ]),
      submissionDate: parsedDate != null
          ? Formatters.isoDate(parsedDate)
          : rawDate,
      status: normalizeStatus(
        read(const ['status', 'Status'], fallback: 'Pending'),
      ),
    );
  }

  /// `pending` / `PENDING` → `Pending`, so badges and actions always match.
  static String normalizeStatus(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return 'Pending';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
