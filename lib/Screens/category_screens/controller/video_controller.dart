import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class VideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  var isVideoPlaying = false.obs; 
  void togglePlayPause() {
    if (videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
      isVideoPlaying.value = false;
    } else {
      videoPlayerController.play();
      isVideoPlaying.value = true;
    }
  }
}
