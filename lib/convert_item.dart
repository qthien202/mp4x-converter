import 'dart:io';

import 'package:flutter/foundation.dart';

class ConvertItem {
  final File file;
  final Uint8List thumbnail;
  double progress;
  String? folderSavePath;

  ConvertItem({
    required this.file,
    required this.thumbnail,
    this.progress = 0,
    this.folderSavePath,
  });
}
