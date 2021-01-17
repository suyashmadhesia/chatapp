import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/crypto.dart';
import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/screens/home.dart';
import 'package:Inbox/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:Inbox/components/reusable.dart'; //first read this file to understand all classes
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

String finalEmail;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    getValidationData().whenComplete(() async {
      if (finalEmail != null) {
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

//const
  final SendNotification notificationData = SendNotification();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _firestore = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;
  final DateTime timeStamp = DateTime.now();
  double screenWidth;
  double screenHeight;

//end
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(6, errorText: 'Password must be at least \n6 characters')
  ]);

  final usernameValidator = MultiValidator([
    RequiredValidator(errorText: 'Username is required'),
    MinLengthValidator(4, errorText: 'Username must be at least 4 characters'),
    MaxLengthValidator(10,
        errorText: 'Username must be less than 10 characters')
  ]);

  String username;
  String password;
  String confirmPassword;
  String name;
  String phone;

  bool showSpinner = false;

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
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Center(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                SizedBox(height: screenHeight * 160),
                Form(
                  key: _formKey,
                  child: Column(
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
                      SizedBox(height: screenHeight * 60),
                      //Username
                      Padding(
                        padding: const EdgeInsets.only(left: 32, right: 32),
                        child: UsernameAndEmailField(
                            onChanged: (String value) {
                              username = value + "@gmail.com";
                              name = value;
                              //print(username);
                            },
                            validation: usernameValidator,
                            hintText: 'Username',
                            icons: Icons.person_outline,
                            regExp: '[a-z_0-9]'),
                      ),
                      SizedBox(height: screenHeight * 45),
                      //Phone number
                      Padding(
                        padding: const EdgeInsets.only(left: 32, right: 32),
                        child: PasswordFields(
                            obsecure: false,
                            onChanged: (value) {
                              phone = value.toString();
                            },
                            type: TextInputType.number,
                            validation: (phone) {
                              String phoneNumber = phone.toString();
                              if (phoneNumber == null || phoneNumber.isEmpty) {
                                return 'Phone Number must be provided';
                              } else if (phoneNumber.length > 10 ||
                                  phoneNumber.length < 10) {
                                return 'Enter valid Phone Number';
                              }
                            },
                            hintText: 'Phone Number',
                            iconName: Icons.phone),
                      ),
                      SizedBox(height: screenHeight * 45),
                      //Password
                      Padding(
                        padding: const EdgeInsets.only(left: 32, right: 32),
                        child: PasswordFields(
                            onChanged: (value) {
                              password = value;
                            },
                            obsecure: true,
                            validation: passwordValidator,
                            hintText: 'Password',
                            iconName: Icons.lock_outline),
                      ),
                      SizedBox(height: screenHeight * 45),
                      //Confirm Password
                      Padding(
                          padding: const EdgeInsets.only(left: 32, right: 32),
                          child: PasswordFields(
                              obsecure: true,
                              validation: (value) => MatchValidator(
                                      errorText: 'Passwords do not match')
                                  .validateMatch(value, password),
                              hintText: 'Confirm Password',
                              iconName: Icons.lock_outline)),

                      SizedBox(height: screenHeight * 60),
                      //Sign Up button
                      Buttons(
                          buttonName: 'Sign Up',
                          onPressed: () async {
                            debugPrint(phone);
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                showSpinner = true;
                              });
                              try {
                                final newUser =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: username, password: password);
                                await notificationData
                                    .topicToSuscribe('/topics/APP');

//Saving data to firestore
                                if (newUser != null) {
                                  User user = FirebaseAuth.instance.currentUser;

                                  _firestore.doc(user.uid).set({
                                    'username': name,
                                    'phoneNumber': '+91' + phone,
                                    'bio': '',
                                    'avtar': '',
                                    'gender': '',
                                    'userId': user.uid,
                                    'password': Encrypt.encrypt(password),
                                    'timeStamp': timeStamp,
                                    'email': '',
                                    'securityQuestion': '',
                                    'securityAnswer': '',
                                    'requestList': <String>[],
                                    'friendsList': <String>[],
                                    'pendingList': <String>[],
                                    'groupsList': <String>[],
                                  }).then((value) async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString('email', username);
                                    Navigator.popUntil(context,
                                        ModalRoute.withName('login_screen'));
                                    Navigator.popUntil(
                                        context,
                                        ModalRoute.withName(
                                            'registration_screen'));
                                    Firebase.initializeApp().whenComplete(() {
                                      //print('initialization Complete');
                                      setState(() {});
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen()));
                                  });
                                }
                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                // print(e);
                                setState(() {
                                  showSpinner = false;
                                });
                                SnackBar snackBar = SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 5),
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'Username already register try using different username !!',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                );
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                              }
                            }
                          }),
                      //Already user
                      SizedBox(height: screenHeight * 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              TextOfPages(textPiece: 'Already a user?'),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              PageChangeButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()));
                                },
                                btnName: 'SIGN IN',
                              ),
                            ]),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
