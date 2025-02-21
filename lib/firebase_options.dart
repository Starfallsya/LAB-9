// firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return _androidOptions; // Only Android configuration
  }

  static const FirebaseOptions _androidOptions = FirebaseOptions(
    apiKey:
        'AIzaSyDNaB0gwV1N_vj6ra4_-K6jRv_4GUk0y48', // From google-services.json
    appId:
        '1:276273650987:android:a343561d0b7739c013396e', // From google-services.json
    messagingSenderId: '276273650987', // From google-services.json
    projectId: 'loginapp-c0398', // From google-services.json
    storageBucket:
        'loginapp-c0398.firebasestorage.app', // From google-services.json
    androidClientId:
        '1:276273650987:android:a343561d0b7739c013396e', // From google-services.json
  );
}
