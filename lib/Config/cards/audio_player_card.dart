import 'dart:io';

import 'package:addpost/Config/constants/widgets.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../Screens/category/controller/audio_controller.dart';
import '../../config/constants/constants.dart';

class AudioCard extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String image;
  final String desc;
  final int index;

  const AudioCard({
    super.key,
    required this.audioUrl,
    required this.title,
    required this.image,
    required this.desc,
    required this.index,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AudioCardState createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  late AudioController audioController;
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    audioController = Get.put(AudioController(), tag: widget.index.toString());
    AudioManager.registerController(audioController);
  }

  @override
  void dispose() {
    audioController.stopAudio();
    AudioManager.unregisterController(audioController);
    Get.delete<AudioController>(tag: widget.index.toString());
    super.dispose();
  }

  Future<void> _showDownloadConfirmationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.download_for_offline,
                color: AppColors.orange,
              ),
              SizedBox(width: 10),
              Text(
                'Подтвердить загрузку',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Хотите скачать этот видеофайл?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Нет',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: Fonts.gilroyMedium,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    isDownloading.value = true;
                    _downloadAndSaveAudio();
                  },
                  child: const Text(
                    'Да',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: Fonts.gilroyMedium,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadAndSaveAudio() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/audio${DateTime.now().millisecondsSinceEpoch}.mp3';
      await _dio.download(widget.audioUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          downloadProgress.value = received / total;
        }
      });

      var box = Hive.box('downloadedAudios');
      await box.add({
        'path': savePath,
        'title': widget.title,
        'image': widget.image,
        'desc': widget.desc
      });

      showSnackBar("Done", "Аудио загружено на", AppColors.grey1);
    } catch (e) {
      showSnackBar("Error", "Error: $e", AppColors.grey1);
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadii.borderRadius10,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey1.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadii.borderRadius10,
            child: ExtendedImage.network(
              widget.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  widget.desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Obx(() => Column(
                      children: [
                        Slider(
                          activeColor: AppColors.orange,
                          inactiveColor: AppColors.orange.withOpacity(0.3),
                          min: 0.0,
                          max: audioController.duration.value.inMilliseconds
                              .toDouble(),
                          value: audioController.position.value.inMilliseconds
                              .toDouble(),
                          onChanged: audioController.seekAudio,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              audioController.position.value
                                  .toString()
                                  .split('.')
                                  .first,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.black2),
                            ),
                            Text(
                              audioController.duration.value
                                  .toString()
                                  .split('.')
                                  .first,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.black2),
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Obx(() => IconButton(
                    icon: Icon(
                      audioController.isPlaying.value
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: AppColors.orange,
                      size: 40,
                    ),
                    onPressed: () => AudioManager.playPauseAudio(
                        widget.audioUrl, widget.index),
                  )),
              Obx(() {
                return isDownloading.value
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.orange,
                            strokeWidth: 4,
                          ),
                          Text(
                            '${(downloadProgress.value * 100).toStringAsFixed(0)}%', // Yüzde metni
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: SvgPicture.asset(
                          Assets.download,
                          colorFilter: const ColorFilter.mode(
                              AppColors.orange, BlendMode.srcIn),
                        ),
                        onPressed: _showDownloadConfirmationDialog,
                      );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class AudioManager {
  static final List<AudioController> _audioControllers = [];

  static void registerController(AudioController controller) {
    _audioControllers.add(controller);
  }

  static void unregisterController(AudioController controller) {
    _audioControllers.remove(controller);
  }

  static Future<void> playPauseAudio(String audioUrl, int index) async {
    final currentController = Get.find<AudioController>(tag: index.toString());

    if (currentController.audioUrl == audioUrl) {
      if (currentController.isPlaying.value) {
        await currentController.audioPlayer.pause();
      } else {
        await currentController.audioPlayer.resume();
      }
    } else {
      await currentController.audioPlayer.pause();
      await currentController.audioPlayer.setSourceUrl(audioUrl);
      await currentController.audioPlayer.resume();
    }

    currentController.audioPlayer.onPlayerComplete.listen((event) {
      currentController.isPlaying.value = false;
      currentController.position.value = Duration.zero;
    });
  }

  static Future<void> pauseAll() async {
    for (var controller in _audioControllers) {
      await controller.audioPlayer.pause();
    }
  }
}
