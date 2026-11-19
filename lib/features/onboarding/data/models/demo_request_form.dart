/// Body of `POST /onboarding/demo-request` (the public "Register" form).
class DemoRequestForm {
  const DemoRequestForm({
    required this.firstName,
    required this.lastName,
    required this.companyEmail,
    required this.companyName,
    required this.companySize,
    required this.phoneNumber,
    required this.businessType,
  });

  final String firstName;
  final String lastName;
  final String companyEmail;
  final String companyName;
  final String companySize;
  final String phoneNumber;
  final String businessType;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'companyEmail': companyEmail,
      'companyName': companyName,
      'companySize': companySize,
      'phoneNumber': phoneNumber,
      'message': businessType,
    };
  }
}
