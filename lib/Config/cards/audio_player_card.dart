import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../config/constants/constants.dart';
import '../../screens/category_screens/controller/audio_controller.dart';
import '../dialogs/audio_download_dialog.dart';

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
  _AudioCardState createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  late AudioController audioController;

  @override
  void initState() {
    super.initState();
    audioController = Get.put(AudioController(), tag: widget.index.toString());
    AudioManager.registerController(audioController);
  }

  @override
  void dispose() {
    AudioManager.unregisterController(audioController);
    Get.delete<AudioController>(tag: widget.index.toString());
    super.dispose();
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
                          max: audioController.duration.value.inMilliseconds.toDouble(),
                          value: audioController.position.value.inMilliseconds.toDouble(),
                          onChanged: audioController.seekAudio,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              audioController.position.value.toString().split('.').first,
                              style: const TextStyle(fontSize: 12, color: AppColors.black2),
                            ),
                            Text(
                              audioController.duration.value.toString().split('.').first,
                              style: const TextStyle(fontSize: 12, color: AppColors.black2),
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
                      audioController.isPlaying.value ? Icons.pause_circle : Icons.play_circle,
                      color: AppColors.orange,
                      size: 40,
                    ),
                    onPressed: () => AudioManager.playPauseAudio(widget.audioUrl, widget.index),
                  )),
              IconButton(
                icon: SvgPicture.asset(
                  Assets.download,
                  colorFilter: const ColorFilter.mode(AppColors.orange, BlendMode.srcIn),
                ),
                onPressed: () {
                  showDownloadConfirmationDialog(
                    context: context,
                    controller: audioController,
                  );
                },
              ),
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
    for (var controller in _audioControllers) {
      if (controller.audioUrl == audioUrl) {
        if (controller.isPlaying.value) {
          await controller.audioPlayer.pause();
        } else {
          await controller.audioPlayer.resume();
        }
      } else {
        await controller.audioPlayer.pause();
      }
    }

    final currentController = Get.find<AudioController>(tag: index.toString());
    if (currentController.isPlaying.value) {
      await currentController.audioPlayer.pause();
    } else {
      await currentController.audioPlayer.setSourceUrl(audioUrl);
      await currentController.audioPlayer.resume();
    }
  }
}
