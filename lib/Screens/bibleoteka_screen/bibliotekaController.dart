// ignore_for_file: file_names
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibliotekaController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  RxInt tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabName.length, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  List<String> tabName = [
    'Video',
    'Aydym',
  ];
  void changeTab(int index) {
    tabIndex.value = index;
    log('it is tabbarvalue ${tabIndex.value} and it is index $index');
  }
}
