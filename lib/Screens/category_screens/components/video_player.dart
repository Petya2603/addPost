import 'package:addpost/Config/theme/theme.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String text;

  const VideoCard({super.key, required this.videoUrl, required this.text});

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          flickManager.flickControlManager?.pause();
          setState(() {});
        }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 7),
        child: Text(
          widget.text,
          style: TextStyle(fontSize: 18, color: black2),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
      Card(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: FlickVideoPlayer(
            flickManager: flickManager,
            flickVideoWithControls: const FlickVideoWithControls(
              controls: FlickPortraitControls(),
            ),
          ),
        ),
      ),
    ]);
  }
}
