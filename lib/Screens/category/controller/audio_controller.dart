import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  RxBool isDownloading = false.obs;
  RxDouble downloadProgress = 0.0.obs;
  String audioUrl = '';

  @override
  void onInit() {
    super.onInit();

    audioPlayer.onDurationChanged.listen((d) {
      duration.value = d;
    });

    audioPlayer.onPositionChanged.listen((p) {
      position.value = p;
    });

    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });

    audioPlayer.onPlayerComplete.listen((event) {
      isPlaying.value = false;
      position.value = Duration.zero;
    });

    audioPlayer.stop();
  }

  Future<void> playPauseAudio(String audioUrl) async {
    this.audioUrl = audioUrl;
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
  Future<void> stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
