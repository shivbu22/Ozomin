import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for Ozomins.
/// Generated from google-services.json — project: ozomin-dee0c
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return android; // Provide dummy/android keys to allow Firebase to initialize and render UI on Web safely
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS platform is not configured yet.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxRK1Ju2_B31HaCUfdbGQ27pGB127DToQ',
    appId: '1:155916865684:android:dbe9e64bb1da60dc1d2481',
    messagingSenderId: '155916865684',
    projectId: 'ozomin-dee0c',
    storageBucket: 'ozomin-dee0c.firebasestorage.app',
  );
}
