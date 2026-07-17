import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadVideo({
    required File videoFile,
    required String caption,
    void Function(double progress)? onProgress,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Upload karne ke liye login zaroori hai');
    }

    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final storageRef = _storage.ref().child('videos/${user.uid}/$fileName');

    final uploadTask = storageRef.putFile(videoFile);

    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    await _firestore.collection('videos').add({
      'url': downloadUrl,
      'caption': caption,
      'uploaderId': user.uid,
      'uploaderPhone': user.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
    });

    return downloadUrl;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getVideoFeed() {
    return _firestore
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> likeVideo(String videoId) async {
    await _firestore.collection('videos').doc(videoId).update({
      'likes': FieldValue.increment(1),
    });
  }
}
