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
    apiKey: 'AIzaSyD_KSmuDitTYhw4fX4TcTXhPVYrlN9Zkg4',
    appId: '1:67848000414:web:81dba0ecebf61e967a3c8f',
    messagingSenderId: '67848000414',
    projectId: 'terra-zero-waste-app-a10c9',
    authDomain: 'terra-zero-waste-app-a10c9.firebaseapp.com',
    storageBucket: 'terra-zero-waste-app-a10c9.appspot.com',
    measurementId: 'G-41RELTGV6B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA3dCI_9TP1UJEbur1VPGfR8sqHg2kjuZY',
    appId: '1:67848000414:android:9055565b02c044fa7a3c8f',
    messagingSenderId: '67848000414',
    projectId: 'terra-zero-waste-app-a10c9',
    storageBucket: 'terra-zero-waste-app-a10c9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKeQiCiwXjSv716OOm5q3UANoJS6LRkFY',
    appId: '1:67848000414:ios:94b964a56f979ded7a3c8f',
    messagingSenderId: '67848000414',
    projectId: 'terra-zero-waste-app-a10c9',
    storageBucket: 'terra-zero-waste-app-a10c9.appspot.com',
    iosClientId: '67848000414-hu3ot3av0gk4ud9pd5g3nl2e214mi9r5.apps.googleusercontent.com',
    iosBundleId: 'com.iktechsol.terraZeroWasteApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAKeQiCiwXjSv716OOm5q3UANoJS6LRkFY',
    appId: '1:67848000414:ios:94b964a56f979ded7a3c8f',
    messagingSenderId: '67848000414',
    projectId: 'terra-zero-waste-app-a10c9',
    storageBucket: 'terra-zero-waste-app-a10c9.appspot.com',
    iosClientId: '67848000414-hu3ot3av0gk4ud9pd5g3nl2e214mi9r5.apps.googleusercontent.com',
    iosBundleId: 'com.iktechsol.terraZeroWasteApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD_KSmuDitTYhw4fX4TcTXhPVYrlN9Zkg4',
    appId: '1:67848000414:web:2472a661545747bc7a3c8f',
    messagingSenderId: '67848000414',
    projectId: 'terra-zero-waste-app-a10c9',
    authDomain: 'terra-zero-waste-app-a10c9.firebaseapp.com',
    storageBucket: 'terra-zero-waste-app-a10c9.appspot.com',
    measurementId: 'G-NP10RTE85C',
  );

}