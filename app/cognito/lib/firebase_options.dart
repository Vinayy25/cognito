// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return windows;
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
    apiKey: 'AIzaSyD42Bg20SAJFXxmI26Uhz0I7quH1cyA9pI',
    appId: '1:513061587003:web:32ae34cb6e5609c142341e',
    messagingSenderId: '513061587003',
    projectId: 'cognito-ai-vinay',
    authDomain: 'cognito-ai-vinay.firebaseapp.com',
    storageBucket: 'cognito-ai-vinay.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADYbewKFmF3BW2_VUbG-BK20RLIYNPkWA',
    appId: '1:513061587003:android:1182cd5b9384853c42341e',
    messagingSenderId: '513061587003',
    projectId: 'cognito-ai-vinay',
    storageBucket: 'cognito-ai-vinay.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6jjEDqM1aPTnZiwN0vMWMxQsulgmibTE',
    appId: '1:513061587003:ios:dccb395e2f42d9af42341e',
    messagingSenderId: '513061587003',
    projectId: 'cognito-ai-vinay',
    storageBucket: 'cognito-ai-vinay.firebasestorage.app',
    androidClientId: '513061587003-6njjqv6r50vagsjf0r69p64rl3i1ilg6.apps.googleusercontent.com',
    iosClientId: '513061587003-juso494huh1b0eg3anur9aurm7qrklj1.apps.googleusercontent.com',
    iosBundleId: 'com.example.cognito',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA6jjEDqM1aPTnZiwN0vMWMxQsulgmibTE',
    appId: '1:513061587003:ios:dccb395e2f42d9af42341e',
    messagingSenderId: '513061587003',
    projectId: 'cognito-ai-vinay',
    storageBucket: 'cognito-ai-vinay.firebasestorage.app',
    androidClientId: '513061587003-6njjqv6r50vagsjf0r69p64rl3i1ilg6.apps.googleusercontent.com',
    iosClientId: '513061587003-juso494huh1b0eg3anur9aurm7qrklj1.apps.googleusercontent.com',
    iosBundleId: 'com.example.cognito',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC8G5dEesxigaYWc6wNcVHkltRueaWQQeg',
    appId: '1:513061587003:web:274922b0825aa56042341e',
    messagingSenderId: '513061587003',
    projectId: 'cognito-ai-vinay',
    authDomain: 'cognito-ai-vinay.firebaseapp.com',
    storageBucket: 'cognito-ai-vinay.firebasestorage.app',
  );

}