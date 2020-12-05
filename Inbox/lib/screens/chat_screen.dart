import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

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
            onPressed: (){
              _auth.signOut();
              Navigator.pop(context);
              Navigator.pushNamed(context, 'login_screen');
          }),
        ),
      ),
    );
  }
}