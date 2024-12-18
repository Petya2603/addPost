import 'package:addpost/screens/bibleoteka_screen/biblioteka_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../config/constants/constants.dart';

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
            return const Center(child: Text('Аудио пока не загружено.'));
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
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: bibliotekaController.currentlyPlayingIndex.value ==
                                  index &&
                              bibliotekaController.isPlaying.value
                          ? AppColors.orange2
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: audio['image'] != null
                                ? ExtendedImage.network(
                                    audio['image'],
                                    width: 85,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    Assets.downloadMusic,
                                    width: 85,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  audio['title'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: Fonts.gilroyBold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  audio['desc'],
                                  style: const TextStyle(
                                      fontSize: 14, color: AppColors.grey2),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: AppColors.orange,
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
