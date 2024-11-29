import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxInt tabIndex = 0.obs;
  RxBool isConnected = true.obs;
  RxBool isLoading = false.obs; // For showing loading state
  RxList<QueryDocumentSnapshot> categories = <QueryDocumentSnapshot>[].obs;
  Rx<TabController?> tabController = Rx<TabController?>(null);

  @override
  void onInit() {
    super.onInit();
    initializeCategories();
  }

  Future<void> initializeCategories() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Category').get();
    categories.value = querySnapshot.docs;
    tabController.value = TabController(length: categories.length, vsync: this);
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      isConnected.value =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isConnected.value = false;
    }
  }

  Future<void> retryConnection() async {
    isLoading.value = true; // Show loading state
    await Future.delayed(const Duration(seconds: 3));
    checkConnection();
    isLoading.value = false; // Hide loading state
  }

  @override
  void dispose() {
    tabController.value?.dispose();
    super.dispose();
  }
}
