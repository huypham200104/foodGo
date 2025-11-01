import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class InputField extends StatefulWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? icon;
  final TextEditingController? controller;

  const InputField({
    super.key,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.icon,
    this.controller,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText ? _isObscured : false,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontFamily: 'Nunito',
            color: Colors.grey[400],
            fontSize: 16,
          ),
          prefixIcon: widget.icon != null 
              ? Icon(widget.icon, color: Colors.grey[400]) 
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
