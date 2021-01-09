import 'package:Inbox/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool firebaseInitialized = false;

  void intialiseFirebase() {
    Firebase.initializeApp().whenComplete(() {
      setState(() {
        firebaseInitialized = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    intialiseFirebase();
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseInitialized) {
      return HomeScreen();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
