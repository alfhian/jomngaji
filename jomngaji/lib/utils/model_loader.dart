import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ModelLoader {
  static Future<String> loadWhisperModelSmall() async {
    final dir = await getApplicationDocumentsDirectory();
    final outPath = "${dir.path}/whisper-small.bin";

    final file = File(outPath);
    if (await file.exists()) {
      return outPath;
    }

    final data = await rootBundle.load("assets/models/whisper-small.bin");
    await file.writeAsBytes(
      data.buffer.asUint8List(),
      flush: true,
    );

    return outPath;
  }
}
