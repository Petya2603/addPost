import 'package:addpost/Config/cards/audio_player_card.dart';
import 'package:addpost/config/cards/banner_cards.dart';
import 'package:addpost/config/cards/video_player_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryView extends StatelessWidget {
  CategoryView({
    super.key,
    required this.categoryname,
    required this.documents,
    required this.loadMore,
  });
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String categoryname;
  final List<DocumentSnapshot> documents;
  final VoidCallback loadMore;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels ==
            scrollInfo.metrics.maxScrollExtent) {
          loadMore();
        }
        return true;
      },
      child: ListView.builder(
        itemCount: documents.length + 1,
        itemBuilder: (context, index) {
          if (index == documents.length) {
            return const Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic>? data =
              documents[index].data() as Map<String, dynamic>?;
          if (data == null ||
              data['category'] == null ||
              data['category']['id'] == null) {
            return const Center(child: Text('В этой категории нет информации'));
          }
          String categoryId = data['category']['id'];

          return buildCategoryCard(categoryId, data, index);
        },
      ),
    );
  }

  Widget buildCategoryCard(
      String? categoryId, Map<String, dynamic> data, int index) {
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
