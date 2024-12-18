import 'dart:developer';
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt tabIndex = 0.obs;
  RxBool isConnected = true.obs;

  void changeTab(int index) {
    tabIndex.value = index;
    log('it is tabbarvalue ${tabIndex.value} and it is index $index');
  }
}