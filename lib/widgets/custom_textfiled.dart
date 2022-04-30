import 'package:flutter/material.dart';
import 'package:twich_clone/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({Key? key, required this.controller, this.onTap})
      : super(key: key);
  final TextEditingController controller;
  final Function(String)? onTap;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onTap,
      controller: controller,
      decoration: const InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          width: 2,
          color: secondaryBackgroundColor,
        )),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: buttonColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
