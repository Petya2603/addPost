import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'constants.dart';

dynamic spinKit() {
  return const Center(
      child: CircularProgressIndicator(color: AppColors.orange));
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

SnackbarController showSnackBar(String title, String subtitle, Color color) {
  if (SnackbarController.isSnackbarBeingShown) {
    SnackbarController.cancelAllSnackbars();
  }
  return Get.snackbar(
    title,
    subtitle,
    snackStyle: SnackStyle.FLOATING,
    titleText: title == ''
        ? const SizedBox.shrink()
        : Text(
            title.tr,
            style: const TextStyle(
                fontFamily: Fonts.gilroySemiBold,
                fontSize: 18,
                color: Colors.white),
          ),
    messageText: Text(
      subtitle.tr,
      style: const TextStyle(
          fontFamily: Fonts.gilroyRegular, fontSize: 16, color: Colors.white),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: color,
    borderRadius: 20.0,
    duration: const Duration(milliseconds: 800),
    margin: const EdgeInsets.all(8),
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
            const Icon(
              Icons.wifi_off,
              size: 75,
              color: AppColors.grey1,
            ),
            const SizedBox(height: 40),
            const Text(
              'У вас нет подключения к Интернету.',
              style: TextStyle(fontSize: 19, color: AppColors.black2),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              child: const Text(
                'Попробуйте еще раз',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: Fonts.gilroyBold),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
