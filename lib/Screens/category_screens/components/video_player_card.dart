// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:io';

import 'package:addpost/Config/constants/constants.dart';
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

class VideoCardd extends StatefulWidget {
  final String videoUrl;
  final String text;
  final String time;

  const VideoCardd({
    super.key,
    required this.videoUrl,
    required this.text,
    required this.time,
  });

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCardd> {
  late FlickManager _controller;
  final firestore = FirebaseFirestore.instance;
  var isDownloading = false;
  var downloadProgress = 0.0;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _controller = FlickManager(
      videoPlayerController: VideoPlayerController.network(
        widget.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
        ),
      )..initialize().then((_) {
          setState(() {
            _controller.flickVideoManager!.videoPlayerController?.pause();
          });
        }),
    );
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
        SnackBar(content: Text('Video downloaded to ${widget.text}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
      Navigator.of(context).pop();
    }
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
            child: FlickVideoPlayer(
              flickManager: _controller,
              flickVideoWithControls: const FlickVideoWithControls(
                controls: FlickPortraitControls(),
              ),
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
