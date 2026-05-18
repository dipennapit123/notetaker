// Firebase options for project notetaker-953d5 (from google-services.json / GoogleService-Info.plist).

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
      case TargetPlatform.macOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCe5ipEbwbx4Fm94WwqkovYRDH_5iCI5is',
    appId: '1:702718628394:web:YOUR_WEB_APP_ID',
    messagingSenderId: '702718628394',
    projectId: 'notetaker-953d5',
    authDomain: 'notetaker-953d5.firebaseapp.com',
    storageBucket: 'notetaker-953d5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCe5ipEbwbx4Fm94WwqkovYRDH_5iCI5is',
    appId: '1:702718628394:android:597039b53485fb46466953',
    messagingSenderId: '702718628394',
    projectId: 'notetaker-953d5',
    storageBucket: 'notetaker-953d5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD792p7rU14_RB4Q6zicNIQ4KGDhpxtBos',
    appId: '1:702718628394:ios:ac1e7723eb50b28b466953',
    messagingSenderId: '702718628394',
    projectId: 'notetaker-953d5',
    storageBucket: 'notetaker-953d5.firebasestorage.app',
    iosClientId: '702718628394-19avu19o3e5af80jom8rodsdqu7612hd.apps.googleusercontent.com',
    iosBundleId: 'com.intelligencetech.note',
  );

}