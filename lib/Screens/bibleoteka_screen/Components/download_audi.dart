import 'package:addpost/Config/theme/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import '../../../Config/constants/constants.dart';
import '../bibliotekaController.dart';

class DownloadedAudiosPage extends StatefulWidget {
  const DownloadedAudiosPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DownloadedAudiosPageState createState() => _DownloadedAudiosPageState();
}

class _DownloadedAudiosPageState extends State<DownloadedAudiosPage> {
  late Box audioBox;
  final BibliotekaController bibliotekaController =
      Get.put(BibliotekaController());

  @override
  void initState() {
    super.initState();
    audioBox = Hive.box('downloadedAudios');
    bibliotekaController.audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    bibliotekaController.audioPlayer.dispose();
    super.dispose();
  }

  void _deleteAudio(int index) {
    audioBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: audioBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return const Center(child: Text('No audio files downloaded.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: box.length,
            itemBuilder: (context, index) {
              var audio = box.getAt(index) as Map;
              return GestureDetector(
                onTap: () {
                  bibliotekaController.playPauseAudio(audio['path'], index);
                },
                child: Obx(
                  () => Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bibliotekaController.currentlyPlayingIndex.value ==
                                  index &&
                              bibliotekaController.isPlaying.value
                          ? orange2
                          : white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: audio['image'] != null
                              ? ExtendedImage.network(
                                  audio['image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  downloadmusic,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                audio['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                audio['desc'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: grey2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: orange,
                          onPressed: () => _deleteAudio(index),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
