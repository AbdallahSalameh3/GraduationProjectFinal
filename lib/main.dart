import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/intro_page1.dart';
import 'db_helper.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  if (kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyDIccwJ4FL8FmGQcJY8sVzL5MCIB59FLv4",
        authDomain: "graduationproject-firebase.firebaseapp.com",
        projectId: "graduationproject-firebase",
        storageBucket: "graduationproject-firebase.firebasestorage.app",
        messagingSenderId: "44879280446",
        appId: "1:44879280446:web:8ce7cfba9b4ea55060946f",
        measurementId: "G-G5V4GHF9G8"));
  }
  else
    {
      await Firebase.initializeApp();
    }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black), // if you want icons to stay black
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: intro_page1(),
    );
  }
}
