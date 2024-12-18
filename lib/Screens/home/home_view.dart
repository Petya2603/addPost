import 'dart:io';

import 'package:addpost/Config/constants/widgets.dart';
import 'package:addpost/Screens/category_screens/category_view.dart';
import 'package:addpost/Screens/home/home_widgets/home_app_bar.dart';
import 'package:addpost/screens/home/controller/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Config/constants/constants.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeView> with TickerProviderStateMixin {
  TabController? tabController;
  final firestore = FirebaseFirestore.instance;
  final HomeController homeController = Get.put(HomeController());
  List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocuments = [];
  Map<String, List<DocumentSnapshot>> categoryData = {};

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Stream<void> _initializeCategoryStream() async* {
    try {
      final querySnapshot = await firestore.collection('Category').get();
      categoryDocuments = querySnapshot.docs;
      for (var doc in categoryDocuments) {
        final categoryName = doc['name'];
        final categorySnapshot = await firestore.collection(categoryName).get();
        categoryData[categoryName] = categorySnapshot.docs;
      }
    } catch (error) {
      rethrow;
    }
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        homeController.isConnected.value = true;
      }
    } on SocketException catch (_) {
      homeController.isConnected.value = false;
    }
  }

  void retryConnection() async {
    homeController.isConnected.value = true;
    await Future.delayed(const Duration(seconds: 3));
    checkConnection();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: StreamBuilder<void>(
        stream: _initializeCategoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading categories"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return spinKit();
          }
          tabController =
              TabController(length: categoryDocuments.length, vsync: this);
          return Obx(() {
            if (homeController.isConnected.value) {
              return Column(
                children: [
                  buildTabBar(categoryDocuments),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(
                      () => IndexedStack(
                        index: homeController.tabIndex.value,
                        children: categoryDocuments.map((doc) {
                          return CategoryView(
                            categoryname: doc['name'],
                            documents: categoryData[doc['name']] ?? [],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return buildNoInternetWidget(onTap: retryConnection);
            }
          });
        },
      ),
    );
  }

  Widget buildTabBar(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs) {
    return TabBar(
      onTap: (index) {
        homeController.changeTab(index);
      },
      isScrollable: true,
      dividerColor: AppColors.white,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      controller: tabController,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      unselectedLabelStyle:
          const TextStyle(fontSize: 16, fontFamily: Fonts.gilroyRegular),
      labelStyle: const TextStyle(
        color: AppColors.white,
        fontFamily: Fonts.gilroyBold,
        fontSize: 16,
      ),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColors.black2,
      ),
      tabs: categoryDocs.map((doc) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Tab(text: doc['name']),
        );
      }).toList(),
    );
  }
}
