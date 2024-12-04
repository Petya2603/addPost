import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  late AudioPlayer audioPlayer;
  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });
    audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });

    audioPlayer.stop();
  }

  Future<void> playPauseAudio(String audioUrl) async {
    if (isPlaying.value) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.setSourceUrl(audioUrl);
      await audioPlayer.resume();
    }
  }

  Future<void> seekAudio(double value) async {
    final newPosition = Duration(milliseconds: value.toInt());
    await audioPlayer.seek(newPosition);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
