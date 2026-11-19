/// Reusable input validation rules.
///
/// Pages keep their own (design approved) error messages and use these
/// predicates so the same rule is applied everywhere.
abstract final class Validators {
  static final RegExp _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _personName = RegExp(r'^[a-zA-Z\s؀-ۿ]+$');
  static final RegExp _phone = RegExp(r'^\+?[1-9]\d{6,14}$');
  static final RegExp _digits = RegExp(r'^[0-9]+$');
  static final RegExp _number = RegExp(r'[0-9]');
  static final RegExp _specialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  static bool isEmail(String value) => _email.hasMatch(value.trim());

  static bool isPersonName(String value) => _personName.hasMatch(value.trim());

  static bool isPhoneNumber(String value) => _phone.hasMatch(value.trim());

  static bool isDigitsOnly(String value) => _digits.hasMatch(value.trim());

  static bool hasNumber(String value) => _number.hasMatch(value);

  static bool hasSpecialCharacter(String value) => _specialChar.hasMatch(value);
}
