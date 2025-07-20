import 'dart:convert';
import 'dart:io';

import 'package:mp4x/notification_service.dart';
import 'package:mp4x/video_progress_item.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import 'convert_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: thumbnailPreview.isNotEmpty || convertingList.isNotEmpty,
        replacement: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(child: buttonSelectFile()),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            buttonSelectFile(),
            const SizedBox(height: 20),
            thumbnailWidget(),
            if (convertingList.isNotEmpty)
              ...convertingList.map(
                (item) => VideoProgressItem(
                  file: item.file,
                  thumbnail: item.thumbnail,
                  progress: item.progress,
                  folderSavePath: item.folderSavePath ?? "",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buttonSelectFile() {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _openFilePicker,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xffFF9898),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Colors.white,
                  radius: Radius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PhosphorIcon(
                        PhosphorIconsFill.fileArrowUp,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Nhấn để chọn file",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget thumbnailWidget() {
    return Visibility(
      visible: selectedFiles.isNotEmpty,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: List.generate(thumbnailPreview.length, (index) {
              return Stack(
                children: [
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          thumbnailPreview[index],
                          width: 150,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 150,
                        child: Text(
                          selectedFiles[index].path
                              .split(Platform.pathSeparator)
                              .last,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFiles.removeAt(index);
                            thumbnailPreview.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedFiles.clear();
                    thumbnailPreview.clear();
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text("Xóa tất cả"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: _convertVideos,
                icon: const Icon(Icons.video_file),
                label: const Text("Convert"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<File> selectedFiles = [];
  List<Uint8List> thumbnailPreview = [];

  List<ConvertItem> convertingList = [];

  Future<void> _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      lockParentWindow: true,
      allowedExtensions: [
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
        'flv',
        'hevc',
        'wmv',
        'mpg',
        'mpeg',
        '3gp',
      ],
    );

    if (result != null) {
      final files =
          result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();
      final List<File> newFiles = [];
      final List<Uint8List> newThumbnails = [];

      for (final file in files) {
        try {
          final thumb = await getVideoThumbnailDesktop(file);
          newThumbnails.add(thumb);
          newFiles.add(file);
        } catch (e) {
          print('⚠️ Không tạo được thumbnail cho: ${file.path}');
        }
      }

      setState(() {
        selectedFiles.addAll(newFiles);
        thumbnailPreview.addAll(newThumbnails);
      });
    } else {
      print('❌ Người dùng đã huỷ chọn file');
    }
  }

  Future<Uint8List> getVideoThumbnailDesktop(File file) async {
    final plugin = FcNativeVideoThumbnail();
    try {
      final tempDir = await getTemporaryDirectory();
      String thumbnailName = const Uuid().v4();
      String thumbnailPath = '${tempDir.path}/$thumbnailName.jpg';
      await plugin.getVideoThumbnail(
        srcFile: file.path,
        destFile: thumbnailPath,
        width: 300,
        height: 300,
        format: 'jpeg',
        quality: 90,
      );
      final thumbnailBytes = await File(thumbnailPath).readAsBytes();
      return thumbnailBytes;
    } catch (e) {
      rethrow;
    }
  }

  List<double> progressList = [];
  List<String> foldersSavePath = [];

  Future<void> _convertVideos() async {
    final outputDir = await getDirectoryPath();
    if (outputDir == null) return;

    // Copy selected files sang convertingList
    final newConverts = List.generate(
      selectedFiles.length,
      (i) =>
          ConvertItem(file: selectedFiles[i], thumbnail: thumbnailPreview[i]),
    );

    setState(() {
      convertingList.addAll(newConverts);
      selectedFiles.clear();
      thumbnailPreview.clear();
    });
    int successCount = 0;
    int failureCount = 0;
    for (int i = 0; i < newConverts.length; i++) {
      final item = newConverts[i];
      final fileName = item.file.path
          .split(Platform.pathSeparator)
          .last
          .replaceAll(RegExp(r'\.\w+$'), '.mp4');
      final savePath = '$outputDir${Platform.pathSeparator}$fileName';
      await deleteIfExists(savePath);
      convertingList[i].folderSavePath = savePath;

      final process = await Process.start('ffmpeg', [
        '-y',
        '-i',
        item.file.path,
        savePath,
      ], runInShell: true);

      Duration? totalDuration;

      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.contains('Duration:')) {
              final match = RegExp(
                r'Duration: (\d+):(\d+):(\d+\.\d+)',
              ).firstMatch(line);
              if (match != null) {
                final hours = int.parse(match.group(1)!);
                final minutes = int.parse(match.group(2)!);
                final seconds = double.parse(match.group(3)!);
                totalDuration = Duration(
                  hours: hours,
                  minutes: minutes,
                  milliseconds: (seconds * 1000).toInt(),
                );
              }
            }

            if (line.contains('time=') && totalDuration != null) {
              final match = RegExp(
                r'time=(\d+):(\d+):(\d+\.\d+)',
              ).firstMatch(line);
              if (match != null) {
                final hours = int.parse(match.group(1)!);
                final minutes = int.parse(match.group(2)!);
                final seconds = double.parse(match.group(3)!);
                final current = Duration(
                  hours: hours,
                  minutes: minutes,
                  milliseconds: (seconds * 1000).toInt(),
                );
                final percent =
                    current.inMilliseconds / totalDuration!.inMilliseconds;

                setState(() {
                  convertingList[i].progress = percent.clamp(0.0, 1.0);
                });
              }
            }
          });

      await process.exitCode.then((exitCode) {
        if (exitCode == 0) {
          successCount++;
          setState(() {
            convertingList[i].progress = 1.0;
          });
        } else {
          failureCount++;
          debugPrint('❌ Convert lỗi: ${item.file.path}');
          setState(() {
            convertingList[i].progress = 0.0;
          });

          // ✅ Thông báo lỗi từng file
          WindowsNotificationService().showNotification(
            id: const Uuid().v4(),
            title: "Lỗi chuyển đổi",
            body:
                "Không thể chuyển đổi: ${item.file.path.split(Platform.pathSeparator).last}",
          );
        }
      });
    }

    // ✅ Thông báo tổng thể
    if (successCount > 0) {
      WindowsNotificationService().showNotification(
        id: const Uuid().v4(),
        title: "Hoàn tất",
        body: "$successCount video đã được chuyển đổi thành công!",
      );
    }

    if (failureCount > 0) {
      WindowsNotificationService().showNotification(
        id: const Uuid().v4(),
        title: "Hoàn tất với lỗi",
        body: "$failureCount video lỗi không chuyển đổi được.",
      );
    }
  }

  Future<void> deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      print('🗑️ File đã tồn tại và đã bị xoá: $path');
    }
  }
}
