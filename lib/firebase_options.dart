// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDr4T9K8opMi5tT0_FSYo9EAWgf5YF4RKU',
    appId: '1:82362499274:android:587699556a87f5d4cf3433',
    messagingSenderId: '82362499274',
    projectId: 'petaholic-4b075',
    databaseURL: 'https://petaholic-4b075-default-rtdb.firebaseio.com',
    storageBucket: 'petaholic-4b075.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtOJ32b9ZO4kne-ufAyNWdCk0rndkO3Nc',
    appId: '1:82362499274:ios:8016f56043284e83cf3433',
    messagingSenderId: '82362499274',
    projectId: 'petaholic-4b075',
    databaseURL: 'https://petaholic-4b075-default-rtdb.firebaseio.com',
    storageBucket: 'petaholic-4b075.appspot.com',
    iosBundleId: 'com.example.petaholiicAdmin',
  );
}
