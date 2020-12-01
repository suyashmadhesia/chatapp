import 'package:Inbox/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/screens/registration_screen.dart';
class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                //push to Login Screen
                Navigator.pushNamed(context, 'login_screen');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ), 
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Login",
                style: TextStyle(
                  fontFamily: 'Montserrat'
                ),
                ),
              ),
              color: Colors.grey[900]
            ),
            SizedBox(
              height: 10.0,
            ),
            //Register button
            FlatButton(
              splashColor: Colors.grey[300],
              onPressed: () {
                //  navigate to Register
                Navigator.pushNamed(context, 'registration_screen');
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: BorderSide(color: Colors.grey[900], width: 2),
              ), 
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Register",
                style: TextStyle(
                  color: Colors.grey[900],
                  fontFamily: 'Montserrat'
                ),
                ),
              ),  
            ),
        ],
        ),
      ),
    );
  }
}