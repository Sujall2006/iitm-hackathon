import "package:flutter/material.dart";

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField(
      {super.key,
        required this.controller,
        required this.hintText,
        required this.labelText,
        required this.icon,
        required this.validator,
        this.isNumber = false,
        this.isPassword = false});

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final IconData icon;
  final bool isPassword;
  final bool isNumber;
  final String? Function(String?)? validator;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.isNumber ? TextInputType.phone : null,
      obscureText: widget.isPassword && obscureText ? true : false,
      validator: widget.validator,
      controller: widget.controller,
      maxLength: widget.isNumber ? 10 : null,
      decoration: InputDecoration(
        counterText: "",
        hintText: widget.hintText,
        labelText: widget.labelText,
        labelStyle: const TextStyle(
            color: Colors.black
        ),
        contentPadding: const EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        prefixIcon: Icon(
          widget.icon,
          color: Colors.black,
          size: 25,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            size: 25,
            color: Colors.black,
          ),
          onPressed: () {
            setState(
                  () {
                obscureText = !obscureText;
              },
            );
          },
        )
            : null,
      ),
    );
  }
}
