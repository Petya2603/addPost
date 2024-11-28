import 'package:addpost/config/cards/banner_cards.dart';
import 'package:addpost/config/constants/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryContent extends StatelessWidget {
  CategoryContent({
    super.key,
    required this.categoryname,
  });
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String categoryname;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: firestore.collection(categoryname).get(),
      builder: (context, collectionSnapshot) {
        if (collectionSnapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        } else if (collectionSnapshot.connectionState == ConnectionState.waiting) {
          return spinKit();
        }

        final List<DocumentSnapshot> documents = collectionSnapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
            String categoryId = data['category']['id'];

            return buildCategoryCard(categoryId, data, index);
          },
        );
      },
    );
  }

  Widget buildCategoryCard(String categoryId, Map<String, dynamic> data, int index) {
    switch (categoryId) {
      case '1':
        return BannerCARD(
          bannerData: data,
        );
      case '2':
        return const Text("ad");
      //  VideoCard(
      //   videoUrl: data['video'][0],
      //   text: data['name'],
      //   time: data['time'],
      // );
      case '3':
        return const Text("ad");
      //  AudioCard(
      //   audioUrl: data['music'][0],
      //   title: data['name'],
      //   image: data['image'][0],
      //   desc: data['desc'],
      //   index: index,
      // );
      default:
        return const Card(
          child: ListTile(
            title: Text('No category'),
          ),
        );
    }
  }
}
