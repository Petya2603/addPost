// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:io';

import 'package:addpost/Config/contstants/constants.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  late FlickManager flickManager;
  final firestore = FirebaseFirestore.instance;
  var isDownloading = false;
  var downloadProgress = 0.0;
  late Dio _dio;

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
                              _downloadAndSaveVideo(setState);
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

  Future<void> _downloadAndSaveVideo(
      void Function(void Function()) updateDialogState) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/video${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _dio.download(widget.videoUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          updateDialogState(() {
            downloadProgress = received / total;
          });
        }
      });

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: savePath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 75,
      );

      var box = Hive.box('downloadedVideos');
      await box.add({
        'path': savePath,
        'name': widget.text,
        'thumbnail': thumbnailPath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video downloaded to $savePath')),
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
  void initState() {
    super.initState();
    _dio = Dio();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.videoUrl)
        ..setLooping(true)
        ..initialize().then((_) {
          if (flickManager.flickControlManager != null) {
            flickManager.flickControlManager!.pause();
          }
        }),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 7),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(fontSize: 18, color: black2),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            IconButton(
              onPressed: _showDownloadConfirmationDialog,
              icon: SvgPicture.asset(
                download,
                colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
              ),
            ),
          ]),
        ),
        Card(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FutureBuilder(
              future: flickManager.flickVideoManager?.videoPlayerController
                  ?.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return FlickVideoPlayer(
                    flickManager: flickManager,
                    flickVideoWithControls: const FlickVideoWithControls(
                      controls: FlickPortraitControls(),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
