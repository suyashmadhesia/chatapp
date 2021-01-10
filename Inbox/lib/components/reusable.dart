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
          fontFamily: 'Montserrat',
          color: Colors.white,
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
  final Function onChanged;
  final Function validation;
  final bool obsecure;
  final TextInputType type;
 
  PasswordFields({@required this.hintText, @required this.iconName, this.onChanged, this.validation,this.obsecure,this.type});
 

  @override
  Widget build(BuildContext context) {
   
  
    return TextFormField(
     //autovalidate: true,
      validator: validation,
      onChanged: onChanged,
      keyboardType: type,
      obscureText: obsecure,
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

//UsernameField and email field
class UsernameAndEmailField extends StatelessWidget {
  
  final String hintText;
  final IconData icons;
  final String helperText;
  final String regExp;
  final Function onChanged;
  final Function validation;
  final Icon suffixIcon;
  

  UsernameAndEmailField({@required this.hintText, this.helperText, @required this.icons, @required this.regExp, this.onChanged, this.validation, this.suffixIcon});

  

  @override
  Widget build(BuildContext context) {
    return TextFormField(
     // autovalidate: true,
      validator: validation,
      onChanged: onChanged,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter(RegExp(regExp), allow: true)//RegEx for  only correct input taken 
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
            Icon(icons, color: Colors.grey[400]),
          suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.0, fontFamily: 'Montserrat'),
        helperText: helperText,
        helperStyle: TextStyle(color: Colors.grey[400], fontSize: 12.0, fontFamily: 'Montserrat'),
      ),
    );
  }
}