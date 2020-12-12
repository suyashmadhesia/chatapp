// import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:Inbox/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';



class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
  
}

class _FriendsScreenState extends State<FriendsScreen> {
  
final _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    
  }

 



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text('ChatApp',
        style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            splashRadius: 16.0,
            onPressed: (){},
            icon: Icon(Icons.notifications))
      ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
            physics: BouncingScrollPhysics(),
            children: [Column(
            children: [
              Text('hello world')
            ],
          ),
                  ]),
      ),
    );
  }
}
