import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';//first read this file to understand all classes


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {



  String username;
  String password;

  

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
              child: UsernameAndEmailField(
                onChanged: (value){
                  username = value;
                },
                
                hintText: 'Username', 
                icons: Icons.person_outline, 
                regExp: '[a-zA-Z0-9_]'),
            ),
            SizedBox(
              height : 50.0
            ),
            //Password
            Padding(
              padding: const EdgeInsets.only(left: 32,right: 32),
              child: PasswordFields(
                onChanged: (value){
                  password = value;
                },
               
                hintText: 'Password', 
                iconName: Icons.vpn_key),
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
            Buttons(
              buttonName:'Sign In',
              onPressed: (){

              },
            ),
            SizedBox(
              height : 50,
            ),
            // Don't Have Account Line
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextOfPages(textPiece: 'Don\'t have a account?') 
                ]
              ),
            ),
      
            //signUP button
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  PageChangeButton(
                    btnName: 'SIGN UP',
                    onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'registration_screen');
                    },
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








