import 'package:addpost/Config/theme/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import '../../../Config/contstants/constants.dart';
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
                child: Obx(
                  () => Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    color: bibliotekaController.currentlyPlayingIndex.value ==
                                index &&
                            bibliotekaController.isPlaying.value
                        ? orange2
                        : music,
                    height: 80,
                    width: 70,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 13, right: 13, top: 5, bottom: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 10, right: 5),
                                  child: audio['image'] != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                          child: ExtendedImage.network(
                                            audio['image'],
                                            width: 85,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(2.0),
                                          child: Image.asset(
                                            downloadmusic,
                                            width: 85,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          audio['title'],
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(
                                          width: 140,
                                          child: Text(
                                            audio['desc'],
                                            style: TextStyle(
                                                fontSize: 12, color: grey2),
                                          )),
                                    ]),
                              ]),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: orange,
                            onPressed: () => _deleteAudio(index),
                          ),
                        ],
                      ),
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
