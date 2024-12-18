// ignore_for_file: file_names
import 'package:addpost/screens/category_screens/components/photo_view_page.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Config/constants/constants.dart';

class BannerProfilePage extends StatelessWidget {
  const BannerProfilePage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });
  final String imageUrl;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 20, fontFamily: Fonts.gilroySemiBold),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(2),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewPage(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: ClipRRect(
                    child: ExtendedImage.network(
                      width: Get.width,
                      imageUrl,
                      height: 350,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Text(
              description,
              style: const TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}
