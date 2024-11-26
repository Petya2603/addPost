import 'dart:io';

import 'package:addpost/Screens/category_screens/category_content.dart';
import 'package:addpost/config/constants/constants.dart';
import 'package:addpost/config/constants/widgets.dart';
import 'package:addpost/config/theme/theme.dart';
import 'package:addpost/screens/bibleoteka_screen/bibleoteka_screen.dart';
import 'package:addpost/screens/home/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? tabController;
  final firestore = FirebaseFirestore.instance;
  final HomeController homeController = Get.put(HomeController());

  Future<int> _initializeCategoryCount() async {
    try {
      final querySnapshot = await firestore.collection('Category').get();
      return querySnapshot.docs.length;
    } catch (error) {
      print('Error initializing category count: $error');
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
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
      appBar: _buildAppBar(),
      body: FutureBuilder<int>(
        future: _initializeCategoryCount(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading categories"));
          } else if (!snapshot.hasData) {
            return spinKit();
          }

          final categoryCount = snapshot.data!;
          tabController = TabController(length: categoryCount, vsync: this);

          return Obx(() {
            if (homeController.isConnected.value) {
              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: firestore.collection('Category').get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading categories"));
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return spinKit();
                  }

                  final categoryDocs = snapshot.data?.docs ?? [];
                  return Column(
                    children: [
                      _buildTabBar(categoryDocs),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Obx(
                          () => IndexedStack(
                            index: homeController.tabIndex.value,
                            children: categoryDocs.map((doc) {
                              return CategoryContent(
                                categoryname: doc['name'],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return buildNoInternetWidget(onTap: retryConnection);
            }
          });
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Image.asset(
        logoadmin,
        height: 40,
        width: 130,
      ),
      scrolledUnderElevation: 0.0,
      actions: [
        IconButton(
          onPressed: () {
            Get.to(const BibliotekaScreen());
          },
          icon: SvgPicture.asset(
            logo,
            colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs) {
    return TabBar(
      onTap: (index) {
        homeController.changeTab(index);
      },
      isScrollable: true,
      dividerColor: white,
      tabAlignment: TabAlignment.start,
      padding: EdgeInsets.zero,
      controller: tabController,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      unselectedLabelStyle: const TextStyle(fontSize: 16, fontFamily: gilroyRegular),
      labelStyle: TextStyle(
        color: white,
        fontFamily: gilroyBold,
        fontSize: 16,
      ),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: black2,
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
