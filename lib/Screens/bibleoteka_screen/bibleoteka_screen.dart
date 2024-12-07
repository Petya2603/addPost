import 'package:addpost/config/constants/constants.dart';
import 'package:addpost/screens/bibleoteka_screen/biblioteka_controller.dart';
import 'package:addpost/screens/bibleoteka_screen/components/download_audi.dart';
import 'package:addpost/screens/bibleoteka_screen/components/download_video.dart';
import 'package:addpost/screens/bibleoteka_screen/contactus_screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibliotekaScreen extends StatefulWidget {
  const BibliotekaScreen({super.key});

  @override
  State<BibliotekaScreen> createState() => _BibliotekaScreenState();
}

class _BibliotekaScreenState extends State<BibliotekaScreen> {
  final BibliotekaController bibliotekaController = Get.put(BibliotekaController());

  final firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Библиотека',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(ContactUsScreen());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.orange),
            child: const Text('Связаться с нами'),
          ),
        ],
        bottom: TabBar(
          isScrollable: false,
          dividerColor: AppColors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicatorColor: AppColors.orange,
          controller: bibliotekaController.tabController,
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          labelStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
          ),
          indicator: const BoxDecoration(
            color: AppColors.orange,
          ),
          tabs: const [
            Tab(text: 'Видео'),
            Tab(text: 'Музыка'),
          ],
        ),
      ),
      body: TabBarView(
        controller: bibliotekaController.tabController,
        children: const [
          DownloadedVideosPage(),
          DownloadedAudiosPage(),
        ],
      ),
    );
  }
}
