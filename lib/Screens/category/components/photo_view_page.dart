import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Config/constants/constants.dart';

class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({super.key, required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              scaleEnabled: true,
              child: ExtendedImage.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.grey2),
              onPressed: () {
                Get.back();
              },
            ),
          )
        ],
      ),
    );
  }
}