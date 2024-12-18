// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../config/constants/constants.dart';
// import '../../screens/category_screens/controller/audio_controller.dart';

// Future<void> showDownloadConfirmationDialog({
//   required BuildContext context,
//   required AudioController controller,
// }) async {
//   await showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadii.borderRadius15,
//             ),
//             title: Row(
//               children: [
//                 Icon(
//                   controller.isDownloading.value ? Icons.download : Icons.download_for_offline,
//                   color: AppColors.orange,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   controller.isDownloading.value ? 'Загрузка...' : 'Подтвердить загрузку',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             content: controller.isDownloading.value
//                 ? Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Obx(() => CircularProgressIndicator(
//                             value: controller.downloadProgress.value,
//                             color: AppColors.orange,
//                           )),
//                       const SizedBox(height: 10),
//                       Obx(() => Text(
//                             '${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black54,
//                             ),
//                           )),
//                     ],
//                   )
//                 : const Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.download,
//                         size: 50,
//                         color: AppColors.orange,
//                       ),
//                       SizedBox(height: 15),
//                       Text(
//                         'Хотите скачать этот аудиофайл?',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black87,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//             actions: controller.isDownloading.value
//                 ? []
//                 : [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop(false);
//                           },
//                           child: const Text(
//                             'Нет',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.black,
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             controller.isDownloading.value = true;
//                             controller.downloadAndSaveAudio();
//                           },
//                           child: const Text(
//                             'Да',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.black,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//           );
//         },
//       );
//     },
//   );
// }