// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:addpost/config/constants/constants.dart';
import 'package:addpost/config/constants/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String text;
  final String time;

  const VideoCard({
    super.key,
    required this.videoUrl,
    required this.text,
    required this.time,
  });

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
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
                    color: AppColors.orange,
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
                          color: AppColors.orange,
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
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download,
                          size: 50,
                          color: AppColors.orange,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Хотите скачать этот видеофайл?',
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
                            child: const Text(
                              'Нет',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isDownloading = true;
                              });
                              shouldDownload = true;
                              _downloadAndSaveVideo(setState);
                            },
                            child: const Text(
                              'Да',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
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

  Future<void> _downloadAndSaveVideo(void Function(void Function()) updateDialogState) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/video${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _dio.download(widget.videoUrl, savePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          updateDialogState(() {
            downloadProgress = received / total;
          });
        }
      });

      showSnackBar("Done", "Видео загружено на ${widget.text}", Colors.green);
    } catch (e) {
      showSnackBar("Error", "Error: $e", Colors.red);
    } finally {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 7),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 18, color: AppColors.black2),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            IconButton(
              onPressed: _showDownloadConfirmationDialog,
              icon: SvgPicture.asset(
                Assets.download,
                colorFilter: const ColorFilter.mode(AppColors.orange, BlendMode.srcIn),
              ),
            ),
          ]),
        ),
        Card(
          child: ClipRRect(
            borderRadius: BorderRadii.borderRadius20,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _controller.value.isInitialized ? VideoPlayer(_controller) : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
