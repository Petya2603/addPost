import 'dart:io';

import 'package:addpost/Config/contstants/constants.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String text;

  const VideoCard({
    super.key,
    required this.videoUrl,
    required this.text,
  });

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late FlickManager flickManager;
  final firestore = FirebaseFirestore.instance;
  late Dio _dio;

// Update your method to generate a thumbnail
  Future<void> _downloadAndSaveVideo() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/video${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Download the video using Dio
      await _dio.download(widget.videoUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });

      // Generate the thumbnail
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: savePath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 75,
      );

      // Save video information to Hive
      var box = Hive.box('downloadedVideos');
      await box.add({
        'path': savePath,
        'name': widget.text,
        'thumbnail': thumbnailPath, // Save the thumbnail path
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video downloaded to $savePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    flickManager = FlickManager(
      // ignore: deprecated_member_use
      videoPlayerController: VideoPlayerController.network(widget.videoUrl)
        ..setLooping(true)
        ..initialize().then((_) {
          flickManager.flickControlManager?.pause();
        }),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
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
            SizedBox(
              width: 120,
              child: Text(
                widget.text,
                style: TextStyle(fontSize: 18, color: black2),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            IconButton(
              onPressed: _downloadAndSaveVideo,
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
              future: flickManager.flickVideoManager!.videoPlayerController!
                  .initialize(),
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
