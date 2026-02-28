import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final opts = DefaultFirebaseOptions.currentPlatform;
  if (opts.apiKey != 'REPLACE_ME') {
    try {
      await Firebase.initializeApp(options: opts);

      print('Firebase initialized successfully');
    } catch (e) {

      print('Firebase initialization failed: $e');
    }
  }

  runApp(const JanataApp());
}
