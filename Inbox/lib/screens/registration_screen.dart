import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:Inbox/reusable/components.dart';//first read this file to understand all classes
//TODO implement password validator
class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final _formKey = GlobalKey<FormState>();


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
                  SizedBox(height: 30.0),
            //Email
                  Padding(
                    padding: const EdgeInsets.only(left: 32, right: 32),
                    child: UsernameAndEmailField(icons: Icons.mail_outline, regExp: '[a-zA-z@.0-9]',hintText: 'Email',
                    helperText: 'In the case you forget your password. This field isn\'t \nrequired',),
                  ),
                  SizedBox(height:40),
            //Sign Up button
                  Buttons(buttonName: 'Sign Up',
                  onPressed: (){
                    //print(username);
                    //print(password);
                    _formKey.currentState.validate();
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
    );
    
  }
}

