// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';



class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;


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
              buttonName: 'Sign Out',
              onPressed: () async{
                _auth.signOut();
                final SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
                  sharedPreferences.remove(
                  'email');
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'login_screen');
              }),
        ),
      ),
    );
  }
}
