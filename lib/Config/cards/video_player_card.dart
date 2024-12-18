// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:addpost/Config/constants/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../Screens/category_screens/components/video_view_page.dart';
import '../constants/constants.dart';

class VideoCard extends StatefulWidget {
  final String videoUrl;
  final String text;
  final String time;

  const VideoCard({
    super.key,
    required this.videoUrl,
    required this.text,
    required this.time,
  });

  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String? _thumbnailPath;
  bool isDownloading = false;
  double downloadProgress = 0.0;
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _generateThumbnail();
  }

  Future<void> _showDownloadConfirmationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.download_for_offline,
                color: AppColors.orange,
              ),
              SizedBox(width: 10),
              Text(
                'Подтвердить загрузку',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: Fonts.gilroyBold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: const Text(
            'Хотите скачать этот видеофайл?',
            style: TextStyle(fontSize: 16, fontFamily: Fonts.gilroyMedium),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Нет',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: Fonts.gilroyMedium,
                    color: Colors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isDownloading = true;
                  });
                  _downloadAndSaveVideo();
                },
                child: const Text(
                  'Да',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: Fonts.gilroyMedium,
                    color: Colors.black,
                  ),
                ),
              ),
            ]),
          ],
        );
      },
    );
  }

  Future<void> _downloadAndSaveVideo() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath =
          '${appDocDir.path}/video${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _dio.download(widget.videoUrl, savePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() {
            downloadProgress = received / total;
          });
        }
      });
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: savePath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 75,
      );
      var box = Hive.box('downloadedVideos');
      await box.add({
        'path': savePath,
        'name': widget.text,
        'thumbnail': thumbnailPath,
      });

      showSnackBar("Done", "Видео загружено на ", Colors.green);
    } catch (e) {
      showSnackBar("Error", "Error: $e", Colors.red);
    } finally {
      setState(() {
        isDownloading = false;
        downloadProgress = 0.0;
      });
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      final String? path = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 250,
        quality: 75,
      );
      setState(() {
        _thumbnailPath = path;
      });
    } catch (e) {
      print("Thumbnail oluşturulamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Get.to(
            () => VideoViewPage(videoUrl: widget.videoUrl, title: widget.text));
      },
      child: Container(
        height: 400,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadii.borderRadius30,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 5),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadii.borderRadius30,
          child: Stack(
            children: [
              _thumbnailPath != null
                  ? Image.file(
                      File(_thumbnailPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 400,
                    )
                  : Center(child: spinKit()),
              Positioned(
                top: 10,
                right: 10,
                child: isDownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.orange,
                            strokeWidth: 4,
                          ),
                          Text(
                            '${(downloadProgress * 100).toStringAsFixed(0)}%', // Yüzde metni
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        onPressed: _showDownloadConfirmationDialog,
                        icon: SvgPicture.asset(
                          Assets.download,
                          colorFilter: const ColorFilter.mode(
                              AppColors.orange, BlendMode.srcIn),
                        ),
                      ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppColors.grey1,
                  size: 50,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.6)),
                    child: Text(
                      widget.text,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 20, fontFamily: Fonts.gilroySemiBold),
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
