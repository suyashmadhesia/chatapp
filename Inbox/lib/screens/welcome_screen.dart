
import 'package:Inbox/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/screens/registration_screen.dart';
// import 'package:Inbox/screens/home.dart';


class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

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
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.black54),
          ),
        ),
        home: Scaffold(
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
                   Firebase.initializeApp().whenComplete(() {
      print('initialization Complete');
      setState(() {});
    });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                  
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ), 
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Sign In",
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color : Colors.white,
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
                splashColor: Colors.grey[400],
                onPressed: () {
                   Firebase.initializeApp().whenComplete(() {
                    print('initialization Complete');
                    setState(() {});
    });
                  //  navigate to Register
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen())); 
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Colors.grey[900], width: 2),
                ), 
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Sign Up",
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
      ),
    );
}
}
