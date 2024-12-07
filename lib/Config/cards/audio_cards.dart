import 'dart:io';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../Config/constants/constants.dart';
import '../../../Config/theme/theme.dart';
import '../../screens/category_screens/controller/audio_controller.dart';

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
  late Dio _dio;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  final AudioController audioController = Get.put(AudioController());

  @override
  void initState() {
    super.initState();
    _dio = Dio();
  }

  Future<void> _showDownloadConfirmationDialog() async {
    bool shouldDownload = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    isDownloading ? Icons.download : Icons.download_for_offline,
                    color: orange,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDownloading ? 'Загрузка...' : 'Подтвердить загрузку',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: isDownloading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value: downloadProgress,
                          color: orange,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${(downloadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download,
                          size: 50,
                          color: orange,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Хотите скачать этот аудиофайл?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              actions: isDownloading
                  ? []
                  : [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              'Нет',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isDownloading = true;
                              });
                              shouldDownload = true;
                              _downloadAndSaveAudio(setState);
                            },
                            child: Text(
                              'Да',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
            );
          },
        );
      },
    );

    if (!shouldDownload) {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
    }
  }

  Future<void> _downloadAndSaveAudio(
      void Function(void Function()) updateDialogState) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/audio${DateTime.now().millisecondsSinceEpoch}.mp3';
      await _dio.download(widget.audioUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          updateDialogState(() {
            downloadProgress = received / total;
          });
        }
      });

      var box = Hive.box('downloadedAudios');
      await box.add({
        'path': savePath,
        'title': widget.title,
        'image': widget.image,
        'desc': widget.desc
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Аудио загружено на ${widget.title}.mp3')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      Navigator.of(context).pop();
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  widget.desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: grey2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Obx(() => Slider(
                      activeColor: orange,
                      inactiveColor: orange.withOpacity(0.3),
                      min: 0.0,
                      max: audioController.duration.value.inMilliseconds
                          .toDouble(),
                      value: audioController.position.value.inMilliseconds
                          .toDouble(),
                      onChanged: audioController.seekAudio,
                    )),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        audioController.position.value
                            .toString()
                            .split('.')
                            .first,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        audioController.duration.value
                            .toString()
                            .split('.')
                            .first,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
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
                      color: orange,
                      size: 40,
                    ),
                    onPressed: () =>
                        audioController.playPauseAudio(widget.audioUrl),
                  )),
              IconButton(
                icon: SvgPicture.asset(
                  download,
                  colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
                ),
                onPressed: _showDownloadConfirmationDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
