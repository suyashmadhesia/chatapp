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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Buttons(
                  buttonName: 'Goto Profile',
                  onPressed: () {
                  
                   Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  })
            ),
            Center(
                child: Buttons(
                    buttonName: 'Sign Out',
                    onPressed: () async{
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
  
                    }),
              ),
          ],
        ),
      ),
    );
  }
}
