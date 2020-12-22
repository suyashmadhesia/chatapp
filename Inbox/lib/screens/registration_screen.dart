// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Inbox/screens/friends_screen.dart';
import 'package:Inbox/screens/home.dart';
import 'package:Inbox/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:Inbox/reusable/components.dart'; //first read this file to understand all classes
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';

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
  final _formKey = GlobalKey<FormState>();

  final _firestore = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;
  final DateTime timeStamp = DateTime.now();
  
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

  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
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
                SizedBox(height: 100),
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
                      SizedBox(height: 40.0),
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
                      SizedBox(height: 30.0),
                      //Password
                      Padding(
                        padding: const EdgeInsets.only(left: 32, right: 32),
                        child: PasswordFields(
                            onChanged: (value) {
                              password = value;
                            },
                            validation: passwordValidator,
                            hintText: 'Password',
                            iconName: Icons.lock_outline),
                      ),
                      SizedBox(height: 30.0),
                      //Confirm Password
                      Padding(
                          padding: const EdgeInsets.only(left: 32, right: 32),
                          child: PasswordFields(
                              validation: (value) => MatchValidator(
                                      errorText: 'Passwords do not match')
                                  .validateMatch(value, password),
                              hintText: 'Confirm Password',
                              iconName: Icons.lock_outline)),

                      SizedBox(height: 40),
                      //Sign Up button
                      Buttons(
                          buttonName: 'Sign Up',
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                showSpinner = true;
                              });
                              try {
                                final newUser =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: username, password: password);
//Saving data to firestore 
                                if (newUser != null) {
                                  User user = FirebaseAuth.instance.currentUser;
                                  _firestore.doc(user.uid).set({
                                    'username': name,
                                    'bio': '',
                                    'avtar': '',
                                    'gender': '',
                                    'userId': user.uid,
                                    'password': password,
                                    'timeStamp' : timeStamp,
                                    'email' : '',
                                    'securityQuestion' : '',
                                    'securityAnswer' :'',
                                    'requestList' : <String>[],
                                    'friendsList' : <String>[],
                                    'pendingList' : <String>[],
                                    
                                  }).then((value) async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setString('email', username);
                                    Navigator.popUntil(context, ModalRoute.withName('login_screen'));
                                    Navigator.popUntil(context, ModalRoute.withName('registration_screen'));
                                    Firebase.initializeApp().whenComplete(() {
                                      print('initialization Complete');
                                      setState(() {});
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeScreen()));
                                  });
                                }
                                setState(()  {                                 
                                  showSpinner = false;
                                });
                              } catch (e) {
                                print(e);
                              }
                            }
                          }),
                      //Already user
                      SizedBox(height: 20),
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
