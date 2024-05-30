import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseimage/firebase_options.dart';
import 'package:flutter/material.dart';
import 'my_app.dart'; // Import your main app widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
