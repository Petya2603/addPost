import 'package:addpost/Config/contstants/widgets.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/category_screens/components/audio_player_card.dart';
import 'package:addpost/Screens/category_screens/components/product_Card.dart';
import 'package:addpost/Screens/category_screens/components/video_player_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryContent extends StatelessWidget {
  CategoryContent({
    super.key,
    required this.categoryname,
  });
  final firestore = FirebaseFirestore.instance;
  final String categoryname;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: firestore.collection(categoryname).get(),
      builder: (context, collectionSnapshot) {
        if (collectionSnapshot.hasError) {
          return const Center(child: Text("Error"));
        } else if (collectionSnapshot.connectionState ==
            ConnectionState.waiting) {
          return Center(child: spinKit());
        }
        final documents = collectionSnapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var data = documents[index];
            var categoryId = data['category']['id'];

            return buildCategoryCard(categoryId, data, index);
          },
        );
      },
    );
  }

  Widget buildCategoryCard(String categoryId, var data, int index) {
    switch (categoryId) {
      case '1':
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 7),
              child: Text(
                data['name'],
                style: TextStyle(fontSize: 18, color: black2),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(
                  PostPage(
                    imageUrl: data['images'][index],
                    title: data['name'],
                    description: data['desc'],
                  ),
                );
              },
              child: ExtendedImage.network(
                data['images'][index],
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      case '2':
        return VideoCard(
          videoUrl: data['video'],
          text: data['name'],
          time: data['time'],
        );
      case '3':
        return AudioCard(
          audioUrl: data['music'],
          title: data['name'],
          image: data['image'],
          desc: data['desc'],
        );
      default:
        return const Card(
          child: ListTile(
            title: Text('Kategori yok'),
          ),
        );
    }
  }
}
