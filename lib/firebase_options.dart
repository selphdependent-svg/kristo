import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-FPaLPOYLQ46MrnBCQfhxc6PUTGg1A7k',
    appId: '1:194501453992:android:ed12ada43273aa342aba9d',
    messagingSenderId: '194501453992',
    projectId: 'kristo-274cd',
    storageBucket: 'kristo-274cd.firebasestorage.app',
  );
}
