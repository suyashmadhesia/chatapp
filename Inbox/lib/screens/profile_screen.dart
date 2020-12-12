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
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: [
          Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
                child: Text(
              'Profile',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Center(
              child: Container(
                height: 120.0,
                width: 120.0,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(60.0))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'prashant',
              style: TextStyle(color: Colors.blue, fontSize: 25.0),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'bio',
                style: TextStyle(color: Colors.blue, fontSize: 15.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Container(
              height: 50.0,
              width: 150.0,
              decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.all(Radius.circular(60.0))),
              child: GestureDetector(
                onTap:() async{
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
  
                    },
                  child: Center(
                      child: Text(
                'Sign Out',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ))),
            ),
          ),
        ],
      )),
    );
  }
}
