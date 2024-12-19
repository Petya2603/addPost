import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class VideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  var isVideoPlaying = false.obs;
  var isVideoInitialized = false.obs;

  void togglePlayPause() {
    if (videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
      isVideoPlaying.value = false;
      videoPlayerController
          .setLooping(true); // Ensure video buffers while paused
    } else {
      videoPlayerController.play();
      isVideoPlaying.value = true;
      videoPlayerController.setLooping(false); // Disable looping when playing
    }
  }
}
