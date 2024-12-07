import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../config/constants/constants.dart';
import '../controller/home_controller.dart';

Widget buildTabBar(List<QueryDocumentSnapshot<Map<String, dynamic>>> categoryDocs, TabController tabController, HomeController homeController) {
  return TabBar(
    onTap: (index) {
      homeController.changeTab(index);
    },
    isScrollable: true,
    dividerColor: AppColors.white,
    tabAlignment: TabAlignment.start,
    padding: EdgeInsets.zero,
    controller: tabController,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    unselectedLabelStyle: const TextStyle(fontSize: 16, fontFamily: Fonts.gilroyRegular),
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
