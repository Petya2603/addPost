// ignore_for_file: file_names
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BibliotekaController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late AudioPlayer audioPlayer = AudioPlayer();
  RxInt currentlyPlayingIndex = (-1).obs;
  RxBool isPlaying = false.obs;
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

  void playPauseAudio(String filePath, int index) async {
    if (currentlyPlayingIndex.value == index && isPlaying.value) {
      await audioPlayer.pause();
      isPlaying.value = false;
    } else {
      if (currentlyPlayingIndex.value != index) {
        await audioPlayer.stop();
      }
      await audioPlayer.play(DeviceFileSource(filePath));
      currentlyPlayingIndex.value = index;
      isPlaying.value = true;
    }
  }
}
