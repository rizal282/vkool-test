import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  // Constructor untuk widget ini
  CustomTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text, // Default TextInputType adalah teks biasa
    this.obscureText = false, // Default tidak mengacak karakter
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
        prefixIcon: Icon(
          keyboardType == TextInputType.emailAddress
              ? Icons.email
              : obscureText
                  ? Icons.lock
                  : Icons.text_fields,
        ),
      ),
      validator: validator,
    );
  }
}
