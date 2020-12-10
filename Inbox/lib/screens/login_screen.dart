import 'dart:async';

import 'package:Inbox/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart'; //first read this file to understand all classes
import 'package:form_field_validator/form_field_validator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

String finalEmail;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    getValidationData().whenComplete(() async {
if(finalEmail != null) {
        Navigator.pushNamed(context, 'home_screen');
      }
    });
    super.initState();
  }

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedEmail = sharedPreferences.getString('email');
    setState(() {
      finalEmail = obtainedEmail;
    });
  }

  bool showSnipper = false;

  final _auth = FirebaseAuth.instance;

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(6, errorText: 'Password must be at least \n6 characters')
  ]);

  final usernameValidator = MultiValidator([
    RequiredValidator(errorText: 'Username is required'),
    MinLengthValidator(4, errorText: 'Username must be at least 4 characters')
  ]);

  String username;
  String password;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        color: Colors.grey[300],
        opacity: 0.5,
        inAsyncCall: showSnipper,
        child: SafeArea(
          child: Center(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 150),
                Form(
                  key: _formKey,
                  child: Column(
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
                            
                              onChanged: (value) {
                                username = value + '@gmail.com';
                              },
                              validation: usernameValidator,
                              hintText: 'Username',
                              icons: Icons.person_outline,
                              regExp: '[a-z0-9_]'),
                        ),
                        SizedBox(height: 50.0),
                        //Password
                        Padding(
                          padding: const EdgeInsets.only(left: 32, right: 32),
                          child: PasswordFields(
                              onChanged: (value) {
                                password = value;
                              },
                              validation: passwordValidator,
                              hintText: 'Password',
                              iconName: Icons.vpn_key),
                        ),
                        //TODO Forget Password Widget Row when backend is
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: <Widget>[
                        //     Padding(
                        //       padding: const EdgeInsets.only(right: 16),
                        //       child: FlatButton(
                        //         onPressed: () {

                        //         },
                        //           child: Text("Forget Password?",
                        //           style: TextStyle(
                        //             fontFamily: 'Montserrat',
                        //             fontSize: 12,
                        //             color: Colors.blue[800]
                        //           ),
                        //           ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 60),
                        //login button
                        Buttons(
                          buttonName: 'Sign In',
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                showSnipper = true;
                              });
                              try {
                                // final user =
                                //     await _auth.signInWithEmailAndPassword(
                                //         email: username, password: password);
                                // if (user != null) {
                                //   Navigator.pop(context);
                                //   Navigator.pushNamed(context, 'home_screen');
                                // }
                                // setState(() {
                                //   showSnipper = false;
                                // });

                                final SharedPreferences sharedPreferences =
                                    await SharedPreferences.getInstance();
                                sharedPreferences.setString(
                                    'email', username);
                                Navigator.pushNamed(context, 'home_screen');
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        // Don't Have Account Line
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                TextOfPages(textPiece: 'Don\'t have a account?')
                              ]),
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
                                    Navigator.pushNamed(
                                        context, 'registration_screen');
                                  },
                                ),
                              ]),
                        )
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
