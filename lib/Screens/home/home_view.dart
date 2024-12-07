import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/constants/widgets.dart';
import '../category_screens/category_view.dart';
import 'controller/home_controller.dart';
import 'home_widgets/home_app_bar.dart';
import 'home_widgets/home_tab_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  TabController? tabController;
  final firestore = FirebaseFirestore.instance;
  final HomeController homeController = Get.put(HomeController());

  Future<int> _initializeCategoryCount() async {
    try {
      final querySnapshot = await firestore.collection('Category').get();
      return querySnapshot.docs.length;
    } catch (error) {
      rethrow;
    }
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
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestore.collection('Category').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading categories"));
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return spinKit();
                  }

                  final categoryDocs = snapshot.data?.docs ?? [];
                  return Column(
                    children: [
                      buildTabBar(categoryDocs, tabController!, homeController),
                      const SizedBox(height: 10),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: categoryDocs.map((doc) {
                            return CategoryView(
                              categoryname: doc['name'],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              return const Text("No Internet");
            }
          });
        },
      ),
    );
  }
}
