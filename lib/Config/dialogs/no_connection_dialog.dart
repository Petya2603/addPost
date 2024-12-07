import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';

void showNoConnectionDialog(BuildContext context, Function onRetry) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadii.borderRadius20),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 50),
            child: Container(
              padding: const EdgeInsets.only(top: 100, left: 15, right: 15),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadii.borderRadius20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'noConnection1'.tr,
                    style: const TextStyle(fontSize: 24.0, color: AppColors.orange, fontFamily: Fonts.gilroyMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Text(
                      'noConnection2'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontFamily: Fonts.gilroyMedium, fontSize: 16.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 1000), () => onRetry());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadii.borderRadius10),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                    child: Text(
                      'noConnection3'.tr,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontFamily: Fonts.gilroyMedium),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              maxRadius: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70),
                child: Image.asset(Assets.noConnection, fit: BoxFit.fill),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
