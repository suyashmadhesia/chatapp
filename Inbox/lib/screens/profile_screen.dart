// import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/search_screen.dart';
import 'package:Inbox/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;
  ProfileScreen({this.profileId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              
              children: [
          Buttons(buttonName: 'SignOut', onPressed: () async{
            _auth.signOut();
            final SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
            sharedPreferences.remove(
            'email');
            Navigator.popUntil(context, ModalRoute.withName('login_screen'));
            Firebase.initializeApp().whenComplete(() {
            print('initialization Complete');
            setState(() {});
          });
            Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  
          })
        ],),
      ),
    );
  }
}
