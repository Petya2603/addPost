import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../config/constants/constants.dart';
import '../../bibleoteka_screen/bibleoteka_screen.dart';

AppBar buildAppBar() {
  return AppBar(
    title: Image.asset(
      Assets.logoAdmin,
      height: 40,
      width: 130,
    ),
    scrolledUnderElevation: 0.0,
    actions: [
      IconButton(
        onPressed: () {
          Get.to(const BibliotekaScreen());
        },
        icon: SvgPicture.asset(
          Assets.logo,
          colorFilter: const ColorFilter.mode(AppColors.orange, BlendMode.srcIn),
        ),
      ),
    ],
  );
}
