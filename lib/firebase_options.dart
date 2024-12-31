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
    apiKey: 'AIzaSyCWVVGhVxxQuZVDv2pF9SIy9kgwzq_belM',
    appId: '1:271665798346:web:ab9303a2cc7328402f2833',
    messagingSenderId: '271665798346',
    projectId: 'event-manager-dfd26',
    authDomain: 'event-manager-dfd26.firebaseapp.com',
    storageBucket: 'event-manager-dfd26.firebasestorage.app',
    measurementId: 'G-TW9NRDSQGS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkA6U4suknekZF2JqGKXwR30CPPEAaR8c',
    appId: '1:271665798346:android:bd0a22ffb747d2432f2833',
    messagingSenderId: '271665798346',
    projectId: 'event-manager-dfd26',
    storageBucket: 'event-manager-dfd26.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRTOWJZCwv8ibRdacpm5A1mM2bNv5UGnE',
    appId: '1:271665798346:ios:28d4701c82a8e8782f2833',
    messagingSenderId: '271665798346',
    projectId: 'event-manager-dfd26',
    storageBucket: 'event-manager-dfd26.firebasestorage.app',
    androidClientId: '271665798346-7fckt5cnuvtcge9vke1pgb1trdushf8d.apps.googleusercontent.com',
    iosClientId: '271665798346-cak3stfiff9ciqqn77q0lq2mdjgb5nb6.apps.googleusercontent.com',
    iosBundleId: 'com.example.eventsManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRTOWJZCwv8ibRdacpm5A1mM2bNv5UGnE',
    appId: '1:271665798346:ios:28d4701c82a8e8782f2833',
    messagingSenderId: '271665798346',
    projectId: 'event-manager-dfd26',
    storageBucket: 'event-manager-dfd26.firebasestorage.app',
    androidClientId:
        '271665798346-7fckt5cnuvtcge9vke1pgb1trdushf8d.apps.googleusercontent.com',
    iosClientId:
        '271665798346-cak3stfiff9ciqqn77q0lq2mdjgb5nb6.apps.googleusercontent.com',
    iosBundleId: 'com.example.eventsManager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCWVVGhVxxQuZVDv2pF9SIy9kgwzq_belM',
    appId: '1:271665798346:web:d2b84305be4232682f2833',
    messagingSenderId: '271665798346',
    projectId: 'event-manager-dfd26',
    authDomain: 'event-manager-dfd26.firebaseapp.com',
    storageBucket: 'event-manager-dfd26.firebasestorage.app',
    measurementId: 'G-RBKP1HS5VY',
  );

}