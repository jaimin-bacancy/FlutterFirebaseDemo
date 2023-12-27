import 'package:flutter/material.dart';

class FormInput extends StatefulWidget {
  final String label;
  final String placeholderText;
  final bool? obscureText;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final String? initialValue;
  final bool? enabled;
  final Function(String) onChanged;

  const FormInput({
    super.key,
    required this.label,
    required this.placeholderText,
    this.obscureText,
    this.textInputAction,
    this.textInputType,
    this.controller,
    this.validator,
    this.initialValue,
    this.enabled,
    required this.onChanged,
  });

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        TextFormField(
          enabled: widget.enabled,
          initialValue: widget.initialValue,
          validator: widget.validator,
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: widget.obscureText ?? false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: widget.placeholderText,
          ),
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          keyboardType: widget.textInputType ?? TextInputType.text,
        ),
      ],
    );
  }
}
