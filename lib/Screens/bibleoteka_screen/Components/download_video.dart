// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:addpost/config/constants/constants.dart';
import 'package:addpost/screens/bibleoteka_screen/components/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DownloadedVideosPage extends StatefulWidget {
  const DownloadedVideosPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DownloadedVideosPageState createState() => _DownloadedVideosPageState();
}

class _DownloadedVideosPageState extends State<DownloadedVideosPage> {
  late Box videoBox;

  @override
  void initState() {
    super.initState();
    videoBox = Hive.box('downloadedVideos');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: videoBox.listenable(),
        builder: (context, Box box, widget) {
          if (box.isEmpty) {
            return const Center(child: Text('Видео еще не загружено.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              var video = box.getAt(index) as Map;
              if (video == null) {
                return Container();
              } else {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          videoPath: video['path'],
                          text: video['name'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          if (video['thumbnail'] != null)
                            Stack(
                              alignment: Alignment.center, // İçerikleri ortalar
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.file(
                                    File(video['thumbnail']),
                                    width: 85,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Icon(
                                  Icons.play_circle_fill,
                                  color: AppColors.grey1
                                      .withOpacity(0.8), // Butonun rengi
                                  size: 30, // Buton boyutu
                                ),
                              ],
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video['name'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: Fonts.gilroyBold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video['description'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grey1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: AppColors.orange,
                            onPressed: () => _deleteVideo(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  void _deleteVideo(int index) {
    videoBox.deleteAt(index);
  }
}
