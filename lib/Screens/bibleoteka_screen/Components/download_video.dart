import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/bibleoteka_screen/Components/VideoPlayerScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

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
            return const Center(child: Text('No videos downloaded yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              var video = box.getAt(index) as Map;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        videoPath: video['path'],
                        text: video['text'],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 3),
                  color: music,
                  height: 80,
                  width: 70,
                  child: Container(
                    margin: const EdgeInsets.only(left: 13, right: 13, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (video['thumbnail'] != null)
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, right: 5),
                                width: 85,
                                height: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2.0),
                                  child: Image.file(
                                    File(video['thumbnail']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    video['name'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  video['time'],
                                  style: TextStyle(fontSize: 10, color: grey2),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: orange,
                          onPressed: () => _deleteVideo(index),
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

  void _deleteVideo(int index) {
    videoBox.deleteAt(index);
  }
}
