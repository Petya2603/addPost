import 'package:addpost/Config/theme/theme.dart';
import 'package:addpost/Screens/bibleoteka_screen/Components/VideoPlayerScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class DownloadedVideosPage extends StatefulWidget {
  @override
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
                      builder: (context) =>
                          VideoPlayerScreen(videoPath: video['path']),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 5),
                  color: music,
                  height: 100,
                  width: 70,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 5),
                    child: Row(
                      children: [
                        if (video['thumbnail'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: Image.file(
                              File(video['thumbnail']),
                              width: 90,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['name'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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
