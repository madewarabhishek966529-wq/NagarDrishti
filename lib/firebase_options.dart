import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAGyYykI4RQ-7gWGq1B38tKACm_6gCAvAs',
    appId: '1:806043921061:web:ecfbf931a19b9698377b4c',
    messagingSenderId: '806043921061',
    projectId: 'nagardrishti-facec',
    authDomain: 'nagardrishti-facec.firebaseapp.com',
    storageBucket: 'nagardrishti-facec.firebasestorage.app',
    measurementId: 'G-J72457DG9G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGwHYxX49RxYErZdroN7i-458lPEVC8j4',
    appId: '1:806043921061:android:85cecdaa9c758319377b4c',
    messagingSenderId: '806043921061',
    projectId: 'nagardrishti-facec',
    storageBucket: 'nagardrishti-facec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCGwHYxX49RxYErZdroN7i-458lPEVC8j4',
    appId: '1:806043921061:android:85cecdaa9c758319377b4c',
    messagingSenderId: '806043921061',
    projectId: 'nagardrishti-facec',
    storageBucket: 'nagardrishti-facec.firebasestorage.app',
  );
}
