import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCVJcBMJiRN4-9qPK7IpCO7x3YlfHM08sc',
    appId: '1:67167409189:web:71914a56d3cfc5490b5bcc',
    messagingSenderId: '67167409189',
    projectId: 'techgear-328d9',
    authDomain: 'techgear-328d9.firebaseapp.com',
    storageBucket: 'techgear-328d9.firebasestorage.app',
    measurementId: 'G-BXCLD3ZKD4',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHJlAyMFWp13d8Um4Mxceh3342zyJrHHg',
    appId: '1:67167409189:android:87a188f47dae9ead0b5bcc',
    messagingSenderId: '67167409189',
    projectId: 'techgear-328d9',
    storageBucket: 'techgear-328d9.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKQy5RH4nBYH3NX8bfv9SUqWK5cF86bjQ',
    appId: '1:67167409189:ios:ed2e941080c61cf20b5bcc',
    messagingSenderId: '67167409189',
    projectId: 'techgear-328d9',
    storageBucket: 'techgear-328d9.firebasestorage.app',
    iosBundleId: 'com.example.computerShop',
  );
}
