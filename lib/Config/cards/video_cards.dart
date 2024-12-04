import 'package:addpost/Config/theme/theme.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../constants/constants.dart';

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
  late FlickManager _flickManager;

  @override
  void initState() {
    super.initState();
    _flickManager = FlickManager(
      // ignore: deprecated_member_use
      videoPlayerController: VideoPlayerController.network(widget.videoUrl),
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: borderRadius30,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: FlickVideoPlayer(
                flickManager: _flickManager,
                flickVideoWithControls: FlickVideoWithControls(
                  controls: FlickPortraitControls(
                    progressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 6,
                      handleColor: orange,
                      playedColor: orange,
                      bufferedColor: Colors.grey.shade400,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style:
                      const TextStyle(fontSize: 20, fontFamily: gilroySemiBold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
