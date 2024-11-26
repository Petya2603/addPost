// ignore_for_file: file_names
import 'package:addpost/screens/category_screens/components/product_card_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PostPage extends StatelessWidget {
  PostPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });
  final String imageUrl;
  final String title;
  final String description;
  final firestore = FirebaseFirestore.instance;

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
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductCardScreen(imageUrl: imageUrl),
                ),
              );
            },
            child: ExtendedImage.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: 250,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
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
