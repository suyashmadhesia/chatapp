// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';



class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _auth = FirebaseAuth.instance;
  // FirebaseUser loggedInUser;

  // void getCurrentUser() async {
  //   final user = await _auth.currentUser();
  //   if (user != null) {
  //     loggedInUser = user;
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Buttons(
              buttonName: 'friends',
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                Navigator.pushNamed(context, 'login_screen');
              }),
        ),
      ),
    );
  }
}
