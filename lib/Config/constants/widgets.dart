import 'package:addpost/Config/theme/theme.dart';
import 'package:flutter/material.dart';

dynamic spinKit() {
  return CircularProgressIndicator(color: orange);
}

dynamic buildTextFormField(
    {required String labelText,
    required String hintText,
    int? maxLines,
    required TextEditingController controller}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: const OutlineInputBorder(),
    ),
    maxLines: maxLines,
  );
}
