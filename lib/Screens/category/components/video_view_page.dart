import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../Config/constants/constants.dart';
import '../controller/video_controller.dart';

class VideoViewPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoViewPage({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPage> {
  final videoController = Get.put(VideoController());

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    videoController.videoPlayerController =
        // ignore: deprecated_member_use
        VideoPlayerController.network(widget.videoUrl)
          ..setLooping(true)
          ..setVolume(1.0);
    await videoController.videoPlayerController.initialize().then((_) {
      videoController.isVideoInitialized.value = true;
      videoController.videoPlayerController.play();
      videoController.isVideoPlaying.value = true; // Update play button state
    }).catchError((error) {
      videoController.isVideoInitialized.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Obx(() {
          return videoController.isVideoInitialized.value
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: videoController
                          .videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(videoController.videoPlayerController),
                    ),
                    VideoProgressIndicator(
                      videoController.videoPlayerController,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: AppColors.orange,
                        backgroundColor: Colors.grey,
                        bufferedColor: AppColors.orange.withOpacity(0.5),
                      ),
                    ),
                  ],
                )
              : const CircularProgressIndicator();
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.white,
        onPressed: videoController.togglePlayPause,
        child: Obx(() {
          return Icon(
            videoController.isVideoPlaying.value
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.black,
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    videoController.videoPlayerController.dispose();
    super.dispose();
  }
}
