import 'dart:io';

import 'package:addpost/Config/contstants/constants.dart';
import 'package:addpost/Config/theme/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AudioCard extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String image;
  final String desc;

  const AudioCard(
      {super.key,
      required this.audioUrl,
      required this.title,
      required this.image,
      required this.desc});

  @override
  AudioCardState createState() => AudioCardState();
}

class AudioCardState extends State<AudioCard> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  late Dio _dio;

  Future<void> _downloadAndSaveAudio() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/audio${DateTime.now().millisecondsSinceEpoch}.mp3';

      await _dio.download(widget.audioUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
        }
      });
      var box = Hive.box('downloadedAudios');
      await box.add({
        'path': savePath,
        'title': widget.title,
        'image': widget.image,
        'desc': widget.desc
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video downloaded to $savePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  void playPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play(UrlSource(widget.audioUrl));
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      color: music,
      child: Container(
        margin: const EdgeInsets.only(left: 13, right: 13, top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              SizedBox(
                height: 70,
                width: 70,
                child: ExtendedImage.network(
                  widget.image,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      widget.desc,
                      style: TextStyle(fontSize: 12, color: grey2),
                    ),
                  ),
                ],
              ),
            ]),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: playPause,
            ),
            IconButton(
              onPressed: _downloadAndSaveAudio,
              icon: SvgPicture.asset(
                download,
                colorFilter: ColorFilter.mode(orange, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
