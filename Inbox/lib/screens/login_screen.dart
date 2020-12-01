import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
            SizedBox(height: 150),
            Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Text(
              "Welcome!",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Mulish',
                fontSize: 36,
              ),
            ),
            SizedBox(height: 40.0),
            //Username
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32),
              child: TextFormField(
                cursorColor: Colors.grey,
                autofocus: false,
                style: TextStyle(
                    fontSize: 18.0, color: Colors.grey, fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  prefixIcon:
                      Icon(Icons.person_outline, color: Colors.grey[400]),
                  hintText: 'Username',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
                ),
              ),
            ),
            SizedBox(
              height : 20.0
            ),
            //Password
            Padding(
              padding: const EdgeInsets.only(left: 32,right: 32),
              child: TextFormField(
                obscureText: true,
                cursorColor: Colors.grey,
                autofocus: false,
                style: TextStyle(
                    fontSize: 18.0, color: Colors.grey, fontFamily: 'Mulish'),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  prefixIcon:
                      Icon(Icons.vpn_key, color: Colors.grey[400]),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
                ),
              ),
            ),
            //Forget Password Widget Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FlatButton(
                    onPressed: () {
                      
                    },
                      child: Text("Forget Password?",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.blue[800]
                      ),
                      ),
                  ),
                ),
              ],
            ),
            SizedBox(height:40),
            //login button
            FlatButton(
              onPressed: () {
                
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ), 
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                child: Text("Login",
                style: TextStyle(
                  fontFamily: 'Montserrat'
                ),
                ),
              ),
              color: Colors.grey[900]
            ),
            SizedBox(
              height : 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Don't have account?",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Mulish',
                      fontSize: 12,
                    ),
                  ), 
                ]
              ),
            ),
      
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'registration_screen');
                    },
                      child: Text("SIGN UP",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: Colors.blue[800]
                      ),
                      ),
                  ), 
                ]
              ),
            )

          ]),
          ],),
        ),
      ),
    );
  }
}


