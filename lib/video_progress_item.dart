import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

class VideoProgressItem extends StatelessWidget {
  final File file;
  final Uint8List thumbnail;
  final double progress;
  final String folderSavePath;

  const VideoProgressItem({
    super.key,
    required this.file,
    required this.thumbnail,
    required this.progress,
    required this.folderSavePath,
  });

  void _openFolder(BuildContext context) async {
    final folderUri = Uri.file(p.dirname(folderSavePath));
    if (await canLaunchUrl(folderUri)) {
      await launchUrl(folderUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể mở thư mục')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              thumbnail,
              width: 80,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.path.split(Platform.pathSeparator).last,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 1.0 ? Colors.blue : Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          progress < 1.0
              ? Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              )
              : IconButton(
                onPressed: () => _openFolder(context),
                icon: const Icon(Icons.folder_open),
                tooltip: 'Mở thư mục',
              ),
        ],
      ),
    );
  }
}
