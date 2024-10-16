// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.file(File(widget.videoPath)),
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video"),
      ),
      body: Center(
        child: Card(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: FlickVideoPlayer(
              flickManager: flickManager,
            ),
          ),
        ),
      ),
    );
  }
}
