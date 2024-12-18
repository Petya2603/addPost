import 'package:addpost/screens/category_screens/banner_profile_page.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/constants.dart';

class BannerCARD extends StatelessWidget {
  final Map<String, dynamic> bannerData;
  const BannerCARD({super.key, required this.bannerData});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => BannerProfilePage(
            imageUrl: bannerData['images'][0],
            title: bannerData['name'],
            description: bannerData['desc'],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadii.borderRadius30,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 5),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius30,
          child: Stack(
            children: [
              ExtendedImage.network(
                bannerData['images'][0],
                fit: BoxFit.contain,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.6)),
                    child: Text(
                      bannerData['name'],
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 20, fontFamily: Fonts.gilroySemiBold),
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
