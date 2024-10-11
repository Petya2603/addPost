import 'package:addpost/Config/theme/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import '../bibliotekaController.dart';

class DownloadedAudiosPage extends StatefulWidget {
  @override
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
            return const Center(child: Text('No audios downloaded yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              var audio = box.getAt(index) as Map;
              return GestureDetector(
                onTap: () {
                  bibliotekaController.playPauseAudio(audio['path'], index);
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 5),
                  color: bibliotekaController.currentlyPlayingIndex.value ==
                              index &&
                          bibliotekaController.isPlaying.value
                      ? orange2
                      : music,
                  height: 100,
                  width: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 5),
                        child: audio['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: ExtendedImage.network(
                                  audio['image'],
                                  width: 90,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: Image.asset(
                                  'assets/images/music.png', // Replace with your default image path
                                  width: 90,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      Column(children: [
                        Text(
                          audio['title'],
                        ),
                        Text(audio['desc']),
                      ]),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: orange,
                        onPressed: () => _deleteAudio(index),
                      ),
                    ],
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
