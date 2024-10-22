import 'dart:io';

import 'package:addpost/Config/theme/theme.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import '../../../Config/constants/constants.dart';
import '../controller/audio_controller.dart';

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
  AudioCardState createState() => AudioCardState();
}

class AudioCardState extends State<AudioCard> {
  late Dio _dio;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  AudioController audioController = Get.put(AudioController());

  @override
  void initState() {
    super.initState();
    _dio = Dio();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
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
        SnackBar(content: Text('Аудио загружено на ${widget.title}')),
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
      margin: const EdgeInsets.only(bottom: 3),
      color: music,
      child: Container(
        margin: const EdgeInsets.only(left: 13, right: 13, top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              SizedBox(
                height: 70,
                width: 70,
                child: ExtendedImage.network(
                  widget.image,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.desc,
                      style: TextStyle(fontSize: 12, color: grey2),
                    ),
                  ),
                ],
              ),
            ]),
            Obx(() => IconButton(
                  icon: Icon(audioController.currentlyPlayingIndex.value ==
                              widget.index &&
                          audioController.isPlaying.value
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () =>
                      audioController.playPause(widget.audioUrl, widget.index),
                )),
            IconButton(
              onPressed: _showDownloadConfirmationDialog,
              icon: SvgPicture.asset(
                download,
                colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
