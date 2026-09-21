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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCt9pNsWSyx_dxxsmufIxkAsDnOEe-3z0U',
    appId: '1:866218340301:web:392a88aae7887d246d5e84',
    messagingSenderId: '866218340301',
    projectId: 'don-de-vie',
    authDomain: 'don-de-vie.firebaseapp.com',
    storageBucket: 'don-de-vie.firebasestorage.app',
    measurementId: 'G-HYJFFTJPML',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtWT-EeHGJF7vW1slsTgsoxU3ATn7pExw',
    appId: '1:866218340301:android:8c493f9d9f47ab1b6d5e84',
    messagingSenderId: '866218340301',
    projectId: 'don-de-vie',
    storageBucket: 'don-de-vie.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZDcmld8CPcDaYnGzLi1v8XuXIC6IBT3s',
    appId: '1:866218340301:ios:e783e22fefc3848d6d5e84',
    messagingSenderId: '866218340301',
    projectId: 'don-de-vie',
    storageBucket: 'don-de-vie.firebasestorage.app',
    iosBundleId: 'com.example.donDeVie',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDZDcmld8CPcDaYnGzLi1v8XuXIC6IBT3s',
    appId: '1:866218340301:ios:e783e22fefc3848d6d5e84',
    messagingSenderId: '866218340301',
    projectId: 'don-de-vie',
    storageBucket: 'don-de-vie.firebasestorage.app',
    iosBundleId: 'com.example.donDeVie',
  );
}
