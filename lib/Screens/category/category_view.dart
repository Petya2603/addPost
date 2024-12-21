import 'package:addpost/Config/cards/audio_player_card.dart';
import 'package:addpost/config/cards/banner_cards.dart';
import 'package:addpost/config/cards/video_player_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({
    super.key,
    required this.categoryname,
    required this.documents,
    required this.loadMore,
  });
  final String categoryname;
  final List<DocumentSnapshot> documents;
  final VoidCallback loadMore;

  @override
  // ignore: library_private_types_in_public_api
  _CategoryViewState createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  var isLoadingMore = false.obs;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoadingMore.value &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          isLoadingMore.value = true;
          widget.loadMore();
          isLoadingMore.value = false;
        }
        return true;
      },
      child: Obx(() => ListView.builder(
            itemCount: widget.documents.length + (isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.documents.length) {
                return const Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic>? data =
                  widget.documents[index].data() as Map<String, dynamic>?;
              if (data == null ||
                  data['category'] == null ||
                  data['category']['id'] == null) {
                return const Center(
                    child: Text('В этой категории нет информации'));
              }
              String categoryId = data['category']['id'];

              return buildCategoryCard(categoryId, data, index);
            },
          )),
    );
  }

  @override
  void dispose() {
    AudioManager.pauseAll(); // Add this line
    super.dispose();
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
          key: ValueKey(index),
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
