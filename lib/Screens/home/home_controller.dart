import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  RxInt tabIndex = 0.obs;

  void changeTab(int index) {
    tabIndex.value = index;
    log('it is tabbarvalue ${tabIndex.value} and it is index $index');
  }
}
