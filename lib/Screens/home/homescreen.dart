import 'dart:io';
import 'package:addpost/Config/constants/constants.dart';
import 'package:addpost/Config/constants/widgets.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/bibleoteka_screen/bibleoteka_screen.dart';
import 'package:addpost/Screens/category_screens/category_content.dart';
import 'package:addpost/Screens/home/home_controller.dart';
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
    final querySnapshot = await firestore.collection('Category').get();
    return querySnapshot.docs.length;
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
      appBar: AppBar(
        title: Image.asset(
          logoadmin,
          height: 40,
          width: 130,
        ),
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
      ),
      body: FutureBuilder<int>(
        future: _initializeCategoryCount(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading categories"));
          } else if (!snapshot.hasData) {
            return Center(child: spinKit());
          }

          final categoryCount = snapshot.data!;
          tabController = TabController(length: categoryCount, vsync: this);

          return Obx(() {
            if (homeController.isConnected.value) {
              return FutureBuilder(
                future: firestore.collection('Category').get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error loading categories"));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: spinKit());
                  }

                  final category = snapshot.data?.docs ?? [];
                  return Column(
                    children: [
                      TabBar(
                        onTap: (index) {
                          homeController.changeTab(index);
                        },
                        isScrollable: true,
                        dividerColor: white,
                        controller: tabController,
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        labelStyle: TextStyle(
                          color: white,
                          fontSize: 16,
                        ),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: black2,
                        ),
                        tabs: category.map((doc) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Tab(text: doc['name']),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Obx(
                          () => IndexedStack(
                            index: homeController.tabIndex.value,
                            children: category.map((doc) {
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
              return _buildNoInternetWidget();
            }
          });
        },
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 75,
                color: grey1,
              ),
              const SizedBox(height: 40),
              Text(
                'У вас нет подключения к Интернету.',
                style: TextStyle(fontSize: 19, color: black2),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: retryConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                child: Text(
                  'Попробуйте еще раз',
                  style: TextStyle(color: white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
