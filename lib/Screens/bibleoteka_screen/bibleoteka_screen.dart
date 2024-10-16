import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/bibleoteka_screen/Components/download_audi.dart';
import 'package:addpost/Screens/bibleoteka_screen/Components/download_video.dart';
import 'package:addpost/Screens/bibleoteka_screen/bibliotekaController.dart';
import 'package:addpost/Screens/bibleoteka_screen/contactus_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibliotekaScreen extends StatefulWidget {
  const BibliotekaScreen({super.key});

  @override
  State<BibliotekaScreen> createState() => _BibliotekaScreenState();
}

class _BibliotekaScreenState extends State<BibliotekaScreen> {
  final BibliotekaController bibliotekaController =
      Get.put(BibliotekaController());

  @override
  void initState() {
    super.initState();
  }

  final firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: black),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Библиотека',
          style: TextStyle(color: black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(const ContactUsScreen());
            },
            style: TextButton.styleFrom(foregroundColor: orange),
            child: const Text('Связаться с нами'),
          ),
        ],
        bottom: TabBar(
          isScrollable: false,
          dividerColor: white,
          controller: bibliotekaController.tabController,
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          labelStyle: TextStyle(
            color: white,
            fontSize: 16,
          ),
          indicator: BoxDecoration(
            color: orange,
          ),
          tabs: [
            SizedBox(width: Get.width, child: const Tab(text: 'Видео')),
            SizedBox(width: Get.width, child: const Tab(text: 'Музыка')),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: bibliotekaController.tabController,
              children: const [
                DownloadedVideosPage(),
                DownloadedAudiosPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
