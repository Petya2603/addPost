import 'package:addpost/config/cards/audio_player_card.dart';
import 'package:addpost/config/cards/banner_cards.dart';
import 'package:addpost/config/cards/video_player_card.dart';
import 'package:addpost/config/constants/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryView extends StatelessWidget {
  CategoryView({
    super.key,
    required this.categoryname,
  });
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String categoryname;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(categoryname).snapshots(),
      builder: (context, collectionSnapshot) {
        if (collectionSnapshot.hasError) {
          return const Center(child: Text("Error loading data"));
        } else if (collectionSnapshot.connectionState == ConnectionState.waiting) {
          return spinKit();
        }

        if (!collectionSnapshot.hasData || collectionSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        final List<DocumentSnapshot> documents = collectionSnapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            Map<String, dynamic>? data = documents[index].data() as Map<String, dynamic>?;

            if (data == null) {
              return const Card(
                child: ListTile(
                  title: Text('Invalid data'),
                ),
              );
            }

            String? categoryId = data['category']?['id'] as String?;
            return buildCategoryCard(categoryId, data, index);
          },
        );
      },
    );
  }

  Widget buildCategoryCard(String? categoryId, Map<String, dynamic> data, int index) {
    switch (categoryId) {
      case '1':
        return BannerCARD(
          bannerData: data,
        );
      case '2':
        return VideoCard(
          videoUrl: data['video'][0],
          text: data['name'],
          time: data['time'],
        );
      case '3':
        return AudioCard(
          audioUrl: data['music'][0],
          title: data['name'],
          image: data['image'][0],
          desc: data['desc'],
          index: index,
        );
      default:
        return const Card(
          child: ListTile(
            title: Text('No category'),
          ),
        );
    }
  }
}
