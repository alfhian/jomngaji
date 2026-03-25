import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'dart:io';

import 'package:ffi/ffi.dart';

class WhisperFfi {
  WhisperFfi._();
  static final WhisperFfi instance = WhisperFfi._();

  ffi.DynamicLibrary? _lib;
  late final _WhisperInit _init;
  late final _WhisperTranscribe _transcribe;
  late final _WhisperFree _free;

  bool _loaded = false;

  /// Init sekali saja dengan path model yang valid.
  Future<void> initOnce(String modelPath) async {
    if (_loaded) {
      print("🧠 WhisperFfi: sudah init, skip.");
      return;
    }

    final file = File(modelPath);
    if (!file.existsSync()) {
      print("❌ WhisperFfi: model tidak ditemukan: $modelPath");
      throw Exception("Model Whisper tidak ditemukan di: $modelPath");
    }

    final size = await file.length();
    if (size == 0) {
      print("❌ WhisperFfi: model kosong.");
      throw Exception("File model Whisper kosong: $modelPath");
    }

    print("🧠 WhisperFfi: init dengan model: $modelPath (size: $size bytes)");

    if (!Platform.isAndroid) {
      throw UnsupportedError('WhisperFfi hanya untuk Android.');
    }

    _lib ??= ffi.DynamicLibrary.open('libwhisper_jni.so');

    _init = _lib!
        .lookup<ffi.NativeFunction<_WhisperInitNative>>('whisper_init_ff')
        .asFunction();

    _transcribe = _lib!
        .lookup<ffi.NativeFunction<_WhisperTranscribeNative>>('whisper_transcribe_ff')
        .asFunction();

    _free = _lib!
        .lookup<ffi.NativeFunction<_WhisperFreeNative>>('whisper_free_ff')
        .asFunction();

    final modelPtr = modelPath.toNativeUtf8();
    final ok = _init(modelPtr.cast()) != 0;
    malloc.free(modelPtr);

    if (!ok) {
      print("❌ WhisperFfi: whisper_init_ff gagal.");
      throw Exception("Gagal init Whisper: $modelPath");
    }

    _loaded = true;
    print("✅ WhisperFfi: init sukses.");
  }

  Future<String> transcribePcmInt16({
    required Int16List pcm,
    required String languageCode,
    required String modelPath,
  }) async {
    if (!_loaded) {
      await initOnce(modelPath);
    }

    final len = pcm.length;
    if (len == 0) {
      print("⚠️ WhisperFfi: PCM kosong → return kosong.");
      return "";
    }

    final samplesPtr = malloc.allocate<ffi.Float>(len * ffi.sizeOf<ffi.Float>());
    for (int i = 0; i < len; i++) {
      samplesPtr[i] = pcm[i] / 32768.0;
    }

    final langPtr = languageCode.toNativeUtf8();
    const maxOut = 4096;
    final outPtr = malloc.allocate<ffi.Int8>(maxOut);

    final written = _transcribe(
      samplesPtr,
      len,
      langPtr.cast(),
      outPtr,
      maxOut,
    );

    String result = "";
    if (written > 0) {
      result = outPtr.cast<Utf8>().toDartString();
    }

    malloc.free(samplesPtr);
    malloc.free(langPtr);
    malloc.free(outPtr);

    print("🧠 WhisperFfi: Transcribe selesai ($written chars): $result");

    return result.trim();
  }

  void dispose() {
    if (_loaded) {
      _free();
      _loaded = false;
      print("🧠 WhisperFfi: model freed.");
    }
  }
}

// === Native typedefs ===

typedef _WhisperInitNative = ffi.Uint8 Function(ffi.Pointer<ffi.Int8>);
typedef _WhisperInit = int Function(ffi.Pointer<ffi.Int8>);

typedef _WhisperTranscribeNative = ffi.Int32 Function(
  ffi.Pointer<ffi.Float>,
  ffi.Int32,
  ffi.Pointer<ffi.Int8>,
  ffi.Pointer<ffi.Int8>,
  ffi.Int32,
);
typedef _WhisperTranscribe = int Function(
  ffi.Pointer<ffi.Float>,
  int,
  ffi.Pointer<ffi.Int8>,
  ffi.Pointer<ffi.Int8>,
  int,
);

typedef _WhisperFreeNative = ffi.Void Function();
typedef _WhisperFree = void Function();
