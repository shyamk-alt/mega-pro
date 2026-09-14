import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() => runApp(const MegaProApp());

class MegaProApp extends StatelessWidget {
  const MegaProApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEGA Pro Downloader',
      theme: ThemeData.dark().copyWith(primaryColor: Colors.red, scaffoldBackgroundColor: const Color(0xFF121212)),
      home: const DownloaderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});
  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final _urlController = TextEditingController();
  double _progress = 0;
  String _status = 'Paste MEGA link above';
  bool _downloading = false;

  Future<void> _download() async {
    if (_urlController.text.isEmpty) return;
    await Permission.storage.request();
    setState(() {_downloading = true; _progress = 0; _status = 'Starting...';});
    try {
      final dir = await getExternalStorageDirectory();
      final savePath = '${dir!.path}/mega_download_${DateTime.now().millisecondsSinceEpoch}.zip';

      // Note: For real MEGA API, integrate mega_dart package. This is direct downloader structure.
      // Using DIO for file download
      final dio = Dio();
      // Placeholder logic - replace with actual MEGA API decryption
      await dio.download(
        _urlController.text,
        savePath,
        onReceiveProgress: (r, t) {
          if (t!= -1) setState(() => _progress = r / t);
        },
      );
      setState(() => _status = 'Saved to: $savePath');
    } catch (e) {
      setState(() => _status = 'Error: $e - Use MEGA app for encrypted links');
    }
    setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MEGA Pro Downloader'), backgroundColor: Colors.redAccent, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _urlController, decoration: InputDecoration(hintText: 'https://mega.nz/file/...', prefixIcon: const Icon(Icons.link), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: _progress, minHeight: 8, backgroundColor: Colors.grey[800], color: Colors.redAccent),
            const SizedBox(height: 10),
            Text('${(_progress*100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, height: 55, child: ElevatedButton.icon(icon: Icon(_downloading? Icons.hourglass_top : Icons.download), label: Text(_downloading? 'Downloading...' : 'DOWNLOAD NOW', style: const TextStyle(fontSize: 18)), onPressed: _downloading? null : _download, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            const Spacer(),
            const Text('Built for Shyam K - Chennai\nMEGA Pro v1.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
