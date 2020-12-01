import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Main login and signUp button
class Buttons extends StatelessWidget {
  
  Buttons({@required this.buttonName, @required this.onPressed});
  final String buttonName;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ), 
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Text(buttonName,
        style: TextStyle(
          fontFamily: 'Montserrat'
        ),
        ),
      ),
      color: Colors.grey[900]
    );
  }
}

//Navigation buttons on page
class PageChangeButton extends StatelessWidget {
  
  PageChangeButton({this.btnName, @required this.onPressed});

  final String btnName;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
        child: Text(btnName,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Colors.blue[800]
        ),
        ),
    );
  }
}

//contants text of Navigations
class TextOfPages extends StatelessWidget {
  
  TextOfPages({@required this.textPiece});
  final String textPiece;

  @override
  Widget build(BuildContext context) {
    return Text(
      textPiece,
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Mulish',
        fontSize: 12,
      ),
    );
  }
}


//PasswordInputs
class PasswordFields extends StatelessWidget {



  final String hintText;
  final IconData iconName;
 
  PasswordFields({@required this.hintText, @required this.iconName});
 

  @override
  Widget build(BuildContext context) {
   
  
    return TextFormField(
      
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
            Icon(iconName, color: Colors.grey[400]),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
      ),
    );
    
  }
  
}

//UsernameField
class UsernameField extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}