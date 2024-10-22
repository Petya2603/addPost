import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages

class AudioController extends GetxController {
  RxInt currentlyPlayingIndex = (-1).obs;
  AudioPlayer audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;

  void playPause(String audioUrl, int index) async {
    if (currentlyPlayingIndex.value == index && isPlaying.value) {
      await audioPlayer.pause();
      isPlaying.value = false;
    } else {
      if (currentlyPlayingIndex.value != index) {
        await audioPlayer.stop();
        currentlyPlayingIndex.value = index;
      }
      await audioPlayer.play(UrlSource(audioUrl));
      isPlaying.value = true;
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
