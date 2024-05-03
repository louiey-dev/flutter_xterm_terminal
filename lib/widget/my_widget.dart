import 'package:flutter/material.dart';

class ExpElevatedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const ExpElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}

class ExpCheckBox extends StatelessWidget {
  final bool value;
  final VoidCallback onChange;
  final String title;

  const ExpCheckBox(
      {super.key,
      required this.value,
      required this.onChange,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (value) {
              onChange();
              // value = value;
            },
          ),
          Text(title),
        ],
      ),
    );
  }
}
