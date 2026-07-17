import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../services/firebase_api.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FirebaseApi _api = FirebaseApi();
  final _captionController = TextEditingController();

  File? _selectedFile;
  VideoPlayerController? _playerController;

  bool _uploading = false;
  double _uploadProgress = 0;
  String? _errorMessage;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);
    _playerController?.dispose();

    final controller = VideoPlayerController.file(file);
    await controller.initialize();

    setState(() {
      _selectedFile = file;
      _playerController = controller;
      _errorMessage = null;
    });

    controller.play();
    controller.setLooping(true);
  }

  Future<void> _uploadSelectedVideo() async {
    if (_selectedFile == null) {
      setState(() => _errorMessage = 'पहले कोई वीडियो चुनें');
      return;
    }

    setState(() {
      _uploading = true;
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      await _api.uploadVideo(
        videoFile: _selectedFile!,
        caption: _captionController.text.trim(),
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('वीडियो अपलोड हो गई! अब वेबसाइट और ऐप दोनों पर दिखेगी 🎉')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _errorMessage = 'अपलोड नहीं हो पाई: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  void dispose() {
    _playerController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('नई वीडियो'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1830),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _playerController != null &&
                          _playerController!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _playerController!.value.aspectRatio,
                              child: VideoPlayer(_playerController!),
                            ),
                            IconButton(
                              iconSize: 54,
                              icon: Icon(
                                _playerController!.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _playerController!.value.isPlaying
                                      ? _playerController!.pause()
                                      : _playerController!.play();
                                });
                              },
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: _pickVideo,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.video_call_rounded,
                                    size: 54, color: Color(0xFF8B84A3)),
                                SizedBox(height: 10),
                                Text('गैलरी से वीडियो चुनें',
                                    style: TextStyle(color: Color(0xFF8B84A3))),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'कैप्शन लिखें...',
                  hintStyle: const TextStyle(color: Color(0xFF5A5470)),
                  filled: true,
                  fillColor: const Color(0xFF1E1830),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              if (_uploading) ...[
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.white12,
                  color: const Color(0xFFFF4D6D),
                ),
                const SizedBox(height: 6),
                Text('${(_uploadProgress * 100).toStringAsFixed(0)}% अपलोड हो रहा है...',
                    style: const TextStyle(color: Color(0xFF8B84A3), fontSize: 12)),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickVideo,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('दूसरी चुनें'),
