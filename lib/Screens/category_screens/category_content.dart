import 'package:addpost/Config/constants/widgets.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/category_screens/components/audio_player_card.dart';
import 'package:addpost/Screens/category_screens/components/product_Card.dart';
import 'package:addpost/Screens/category_screens/components/video_player_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CategoryContent extends StatefulWidget {
  const CategoryContent({
    super.key,
    required this.categoryname,
  });
  final String categoryname;

  @override
  State<CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends State<CategoryContent> {
  final firestore = FirebaseFirestore.instance;
  static const _pageSize = 5;
  final PagingController<DocumentSnapshot?, DocumentSnapshot>
      _pagingController = PagingController(firstPageKey: null);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(widget.categoryname)
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);
      if (pageKey != null) {
        query = query.startAfterDocument(pageKey);
      }

      final newPage = await query.get();
      final isLastPage = newPage.docs.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newPage.docs);
      } else {
        _pagingController.appendPage(newPage.docs, newPage.docs.last);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PagedListView<DocumentSnapshot?, DocumentSnapshot>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<DocumentSnapshot>(
          itemBuilder: (context, document, index) {
            final data = document.data() as Map<String, dynamic>;
            final categoryId = data['category']['id'];
            return buildCategoryCard(categoryId, data, index);
          },
        ),
      ),
    );
  }

  Widget buildCategoryCard(String categoryId, var data, int index) {
    switch (categoryId) {
      case '1':
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 5, right: 5, top: 5),
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
                    imageUrl: data['images'][0],
                    title: data['name'],
                    description: data['desc'],
                  ),
                );
              },
              child: ExtendedImage.network(
                data['images'][0],
                fit: BoxFit.contain,
              ),
            ),
          ],
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
            title: Text('Kategori yok'),
          ),
        );
    }
  }
}
