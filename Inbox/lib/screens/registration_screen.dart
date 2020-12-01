import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     body: SafeArea(
       child: Center(
         child: ListView(
           physics: BouncingScrollPhysics(),
           children: <Widget>[
             SizedBox(height: 50),
             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                 //sign UP Text
                Text(
                  "SIGN UP",
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
                    inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp("[a-z0-9_]"))//RegEx Username Contains only a-z and underscores
                    ],
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
                    height : 30.0
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
                          Icon(Icons.lock_outline, color: Colors.grey[400]),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
                SizedBox(
                    height : 30.0
                  ),
                  //Confirm Password
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
                          Icon(Icons.lock_outline, color: Colors.grey[400]),
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
            //Email
                Padding(
                  padding: const EdgeInsets.only(left: 32, right: 32),
                  child: TextFormField(
                   inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z_0-9.@]"))//RegEx for Email
                   ],
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
                          Icon(Icons.mail_outline, color: Colors.grey[400]),
                      hintText: 'Email',
                      helperText: 'In the case you forget your password. This field is not \nrequired.',
                      helperStyle: TextStyle(color: Colors.grey[400], fontSize: 12.0, fontFamily: 'Montserrat'),
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
                SizedBox(height:40),
            //Sign Up button
                FlatButton(
                  onPressed: () {
                    
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ), 
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    child: Text("Sign Up",
                    style: TextStyle(
                      fontFamily: 'Montserrat'
                    ),
                    ),
                  ),
                  color: Colors.grey[900]
                ),
                //Already user 
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Already user?",
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
                          Navigator.pop(context);
                          Navigator.pushNamed(context, 'login_screen');
                        },
                          child: Text("SIGN IN",
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
               ],
             )
           ],
         ),
         ),
       ),
    );
  }
}