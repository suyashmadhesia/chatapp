// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:Inbox/reusable/components.dart';//first read this file to understand all classes
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  //TODO make reference store in firebase for saving email(username) and password separately
  //later use it for stayed in loggedIN process;

  final _formKey = GlobalKey<FormState>();

  
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
  String confirmPassword;  

  bool showSpinner = false;


  @override
  Widget build(BuildContext context) {
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
                        
                      onChanged: (String value){
                        username = value+"@gmail.com";
                        //print(username);
                      },
                      
                      
                      
                      validation: usernameValidator,

                      
                      hintText: 'Username',
                      icons: Icons.person_outline, 
                      regExp: '[a-z_0-9]'),
                    ),
                    SizedBox(
                        height : 30.0
                      ),
                      //Password
                    Padding(
                      padding: const EdgeInsets.only(left: 32,right: 32),
                      
                      child: PasswordFields(
                        onChanged: (value){
                          password = value;
                        },
                        validation: passwordValidator,

                       
                        hintText: 'Password', iconName: Icons.lock_outline),
                    ),
                    SizedBox(
                        height : 30.0
                      ),
                      //Confirm Password
                    Padding(
                      padding: const EdgeInsets.only(left: 32,right: 32),
                      child: PasswordFields(
                        
                        validation: (value) => MatchValidator(errorText: 'Passwords do not match').validateMatch(value, password),
                        hintText: 'Confirm Password', iconName: Icons.lock_outline)
                    ),
             
                    SizedBox(height:40),
              //Sign Up button
                    Buttons(buttonName: 'Sign Up',
                    onPressed: () async {
                      if(_formKey.currentState.validate()){
                        setState(() {
                          showSpinner = true;
                        });
                        try{

                          final newUser = await _auth.createUserWithEmailAndPassword(email: username, password: password);
                          if(newUser != null){
                          Navigator.pop(context);
                          Navigator.pushNamed(context, 'chat_screen');}
                        setState((){
                          showSpinner = false;
                        });
                        
                        }
                        catch(e){
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
                        ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          PageChangeButton(onPressed: (){
                            Navigator.pop(context);
                            Navigator.pushNamed(context, 'login_screen');
                          },
                          btnName: 'SIGN IN',
                          ), 
                        ]
                      ),
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

