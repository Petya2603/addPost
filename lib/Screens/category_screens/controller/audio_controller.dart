import 'dart:io';

import 'package:addpost/Config/constants/widgets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class AudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  RxBool isDownloading = false.obs; // İndirme durumu
  RxDouble downloadProgress = 0.0.obs;
  String audioUrl = '';

  @override
  void onInit() {
    super.onInit();

    audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });

    audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });

    audioPlayer.stop();
  }

  Future<void> playPauseAudio(String audioUrl) async {
    this.audioUrl = audioUrl;
    if (isPlaying.value) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.setSourceUrl(audioUrl);
      await audioPlayer.resume();
    }
  }

  Future<void> seekAudio(double value) async {
    final newPosition = Duration(milliseconds: value.toInt());
    await audioPlayer.seek(newPosition);
  }

  Future<void> downloadAndSaveAudio() async {
    try {
      isDownloading.value = true; // İndirme başladığında
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/audio${DateTime.now().millisecondsSinceEpoch}.mp3';
      Dio dio = Dio();

      await dio.download(audioUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress.value = received / total;
        }
      });

      var box = Hive.box('downloadedAudios');
      await box.add({'path': savePath, 'title': audioUrl, 'desc': audioUrl});

      showSnackBar("Done", "Аудио загружено на $audioUrl", Colors.green);
    } catch (e) {
      showSnackBar("Error", "Error: $e", Colors.red);
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
