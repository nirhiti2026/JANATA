// Paste your Firebase web config into the `firebaseOptions` below.
// You can generate this using the FlutterFire CLI or paste the web API config
// from your Firebase project settings. Example:
// const firebaseOptions = FirebaseOptions(
//   apiKey: '...',
//   authDomain: '...'
//   projectId: '...'
//   messagingSenderId: '...'
//   appId: '...'
// );

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  // Replace the body of this getter with your project's FirebaseOptions.
  static FirebaseOptions get currentPlatform => FirebaseOptions(
          apiKey: "AIzaSyA9CdfqquPJGjzQY4aPIMSRfUAIKUR8C38",
          authDomain: "janata-9ff3f.firebaseapp.com",
          projectId: "janata-9ff3f",
          storageBucket: "janata-9ff3f.firebasestorage.app",
          messagingSenderId: "1012866708415",
          appId: "1:1012866708415:web:512d9c1f32f0c49f6a270a",
          measurementId: "G-Q3SMMSBX78"
      );
}
