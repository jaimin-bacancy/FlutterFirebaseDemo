import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  const FormButton(
      {super.key, required this.label, required this.onButtonPress});
  final String label;
  final Function onButtonPress;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onButtonPress(),
      child: Text(label),
    );
  }
}
