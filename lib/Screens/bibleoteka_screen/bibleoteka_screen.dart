import 'package:addpost/Config/contstants/constants.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/bibleoteka_screen/bibliotekaController.dart';
import 'package:addpost/Screens/bibleoteka_screen/contactus_screens.dart';
import 'package:addpost/Screens/category_screens/components/audio_player.dart';
import 'package:addpost/Screens/category_screens/components/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibliotekaScreen extends StatefulWidget {
  const BibliotekaScreen({super.key});

  @override
  State<BibliotekaScreen> createState() => _BibliotekaScreenState();
}

class _BibliotekaScreenState extends State<BibliotekaScreen> {
  List<Map<String, dynamic>> videos = [];
  List<Map<String, dynamic>> audios = [];
  final BibliotekaController bibliotekaController =
      Get.put(BibliotekaController());

  @override
  void initState() {
    super.initState();
    fetchCollection();
  }

  Future<void> fetchCollection() async {
    for (String collectionName in tabName) {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var category = data['category'];
        if (category != null && category['name'] == 'Видео') {
          videos.add(data);
        } else if (category != null && category['name'] == 'Музыка') {
          audios.add(data);
        }
      }
    }
    setState(() {});
  }

  final firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Библиотека',
              style: TextStyle(color: black),
            ),
            TextButton(
              onPressed: () {
                Get.to(const ContactUsScreen());
              },
              style: TextButton.styleFrom(foregroundColor: orange),
              child: const Text('Связаться с нами'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
            child: TabBar(
              isScrollable: false,
              controller: bibliotekaController.tabController,
              labelColor: orange,
              unselectedLabelColor: black,
              indicatorColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Видео'),
                Tab(text: 'Музыка'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: bibliotekaController.tabController,
              children: [
                ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    var video = videos[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          Scaffold(
                              appBar: AppBar(),
                              body: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    VideoCard(
                                        videoUrl: video['video'],
                                        text: video['name']),
                                  ])),
                        );
                      },
                      child: Container(
                        height: 100,
                        margin:
                            const EdgeInsets.only(left: 3, right: 3, top: 2),
                        color: orange2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                video['name'],
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ListView.builder(
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    var audio = audios[index];
                    return AudioCard(
                      audioUrl: audio['music'],
                      title: audio['name'],
                      image: audio['image'],
                      desc: audio['desc'],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
