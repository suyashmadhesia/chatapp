import 'dart:async';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/crypto.dart';
import 'package:Inbox/screens/registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/components/reusable.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

String finalEmail;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> isAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', username);
    Navigator.pop(context);
    Firebase.initializeApp().whenComplete(() {
      // print('initialization Complete');
      setState(() {});
    });
    Navigator.popUntil(context, ModalRoute.withName('login_screen'));
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  bool showSnipper = false;

  final _auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();

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
  String userUid;
  double screenHeight;
  double screenWidth;

  final _formKey = GlobalKey<FormState>();

  //Functions

  saveDeviceToken(uid) async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      final tokens =
          FirebaseFirestore.instance.collection('users/' + uid + '/tokens');
      tokens.doc(fcmToken).set({
        'tokenId': fcmToken,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      key: _scaffoldKey,
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
                SizedBox(height: screenHeight * 200),
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
                        SizedBox(height: screenHeight * 60),
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
                        SizedBox(height: screenHeight * 60),
                        //Password
                        Padding(
                          padding: const EdgeInsets.only(left: 32, right: 32),
                          child: PasswordFields(
                              obsecure: true,
                              onChanged: (value) {
                                password = value;
                              },
                              validation: passwordValidator,
                              hintText: 'Password',
                              iconName: Icons.vpn_key),
                        ),

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
                        SizedBox(height: screenHeight * 70),
                        //login button
                        Buttons(
                            buttonName: 'Sign In',
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                setState(() {
                                  showSnipper = true;
                                });
                                try {
                                  var encryptedPassword =
                                      Encrypt.encrypt(password);
                                  print(encryptedPassword);
                                  final user =
                                      await _auth.signInWithEmailAndPassword(
                                          email: username, password: password);
                                  if (user != null) {
                                    final currentUserId = _auth.currentUser.uid;

                                    isAuth();
                                    await saveDeviceToken(currentUserId);
                                  }
                                  setState(() {
                                    showSnipper = false;
                                  });
                                } catch (e) {
                                  // print(e);
                                  setState(() {
                                    showSnipper = false;
                                  });
                                  SnackBar snackBar = SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        'Username or password is wrong !!!',
                                        style: TextStyle(
                                          color: Colors.white,
                                        )),
                                  );
                                  _scaffoldKey.currentState
                                      .showSnackBar(snackBar);
                                }
                              }
                            }),
                        SizedBox(
                          height: screenHeight * 60,
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

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RegistrationScreen()));
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
