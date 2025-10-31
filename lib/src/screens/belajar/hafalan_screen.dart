import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/record_service.dart';
import 'package:path_provider/path_provider.dart';

class HafalanScreen extends StatefulWidget {
  final String? ayat;

  const HafalanScreen({super.key, this.ayat});

  @override
  State<HafalanScreen> createState() => _HafalanScreenState();
}

class _HafalanScreenState extends State<HafalanScreen> {
  final RecordService _recordService = RecordService();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlayingExample = false;
  String? _recordedFilePath;

  Future<void> _playExample() async {
    if (_isPlayingExample) {
      await _player.stop();
      setState(() => _isPlayingExample = false);
    } else {
      // audio contoh lokal (nanti bisa ganti dari asset lain)
      await _player.play(AssetSource('audio/example_surah.mp3'));
      setState(() => _isPlayingExample = true);

      _player.onPlayerComplete.listen((_) {
        setState(() => _isPlayingExample = false);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recordService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
    } else {
      final path = await _recordService.startRecording();
      setState(() {
        _isRecording = true;
        _recordedFilePath = path;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _recordService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hafalan Interaktif'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mosque, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Latihan Hafalan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),

              // 🔊 Tombol play contoh
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isPlayingExample ? Colors.orange : Colors.blue,
                  minimumSize: const Size(240, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _playExample,
                icon: Icon(
                    _isPlayingExample ? Icons.stop : Icons.play_arrow_rounded),
                label: Text(_isPlayingExample
                    ? 'Hentikan Contoh'
                    : 'Dengarkan Contoh Bacaan'),
              ),
              const SizedBox(height: 30),

              // 🎙️ Tombol record hafalan
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.green,
                  minimumSize: const Size(240, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _toggleRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label:
                    Text(_isRecording ? 'Stop Recording' : 'Rekam Hafalan Saya'),
              ),
              const SizedBox(height: 30),

              // 📁 Tampilkan hasil rekaman
              if (_recordedFilePath != null && !_isRecording)
                Column(
                  children: [
                    const Text('Rekaman tersimpan di:',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      _recordedFilePath!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
