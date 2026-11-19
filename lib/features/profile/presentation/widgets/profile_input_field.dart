import 'package:flutter/material.dart';

/// Labeled text field used by the profile settings cards.
class ProfileInputField extends StatelessWidget {
  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.readOnly = false,
    this.isLocked = false,
    this.preventAutofill = false,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final bool readOnly;
  final bool isLocked;
  final bool preventAutofill;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          readOnly: readOnly || isLocked,
          enabled: !isLocked,
          canRequestFocus: !isLocked,
          mouseCursor: isLocked
              ? SystemMouseCursors.basic
              : SystemMouseCursors.text,
          keyboardType: keyboardType,
          validator: validator,
          autofillHints: preventAutofill ? const [] : autofillHints,
          style: TextStyle(
            fontSize: 14,
            color: isLocked ? const Color(0xFF475569) : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: (readOnly || isLocked)
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFFAFAFA),
            suffixIcon: isPassword && onToggleVisibility != null
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF1D4ED8),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
