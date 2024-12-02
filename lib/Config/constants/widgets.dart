import 'package:addpost/config/theme/theme.dart';
import 'package:flutter/material.dart';

dynamic spinKit() {
  return Center(child: CircularProgressIndicator(color: orange));
}

dynamic buildTextFormField({required String labelText, required String hintText, int? maxLines, required TextEditingController controller}) {
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

Widget buildNoInternetWidget({required Function() onTap}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 75,
              color: grey1,
            ),
            const SizedBox(height: 40),
            Text(
              'У вас нет подключения к Интернету.',
              style: TextStyle(fontSize: 19, color: black2),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              child: Text(
                'Попробуйте еще раз',
                style: TextStyle(color: white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}