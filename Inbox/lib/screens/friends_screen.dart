// import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';



class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _auth = FirebaseAuth.instance;
 

    @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print('initialization Complete');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Buttons(
              buttonName: 'Goto Profile',
              onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              })
        ),
      ),
    );
  }
}
