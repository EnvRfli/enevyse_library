import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool readOnly;

  /// When true, the field looks visually disabled (muted background & text color)
  /// and cannot be interacted with at all.
  final bool disabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.disabled = false,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled;
    final disabledFill = Colors.grey.shade100;
    final disabledTextColor = Colors.grey.shade400;
    final disabledIconColor = Colors.grey.shade300;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      readOnly: widget.readOnly || isDisabled,
      enabled: !isDisabled,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      style: isDisabled
          ? Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: disabledTextColor)
          : Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: isDisabled,
        fillColor: isDisabled ? disabledFill : null,
        prefixIcon: Icon(
          widget.prefixIcon,
          size: 20.w,
          color: isDisabled ? disabledIconColor : null,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20.w,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        // Override border to look muted when disabled
        enabledBorder: isDisabled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              )
            : null,
        disabledBorder: isDisabled
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              )
            : null,
      ),
    );
  }
}
