import 'package:Inbox/screens/home.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/search_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';

//TODO figur out how to make user stay in login_screen after succesfull authentication watch on youtube;
//TODO Use shared_preferences for stay in login mode by using firestore email refs fields.
// void main() => runApp(ChatApp());

// class ChatApp extends StatefulWidget {
//   @override
//   _ChatAppState createState() => _ChatAppState();
// }

// class _ChatAppState extends State<ChatApp> {
  // @override
  // void initState() {
  //   super.initState();
  //   Firebase.initializeApp().whenComplete(() {
  //     print('initialization Complete');
  //     setState(() {});
  //   });
  // }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(

//           // Navigation Bar
//           bottomNavigationBar: CurvedNavigationBar(
//             color: Colors.black,
//             backgroundColor: Colors.white,
//             height: 50,
//             items: <Widget>[
//               Icon(Icons.favorite, size: 20, color: Colors.white,),
//               Icon(Icons.add, size: 30, color: Colors.white,),
//               Icon(Icons.person, size: 20, color: Colors.white,),
//             ],
//             // animationDuration: Duration(milliseconds: 200),
//             index: 1,
//             // animationCurve: Curves.bounceInOut,
//             onTap: (index) {
//               //Handle button tap
//             },
//           ),
//         ),


//         theme: ThemeData.dark().copyWith(
//           textTheme: TextTheme(
//             bodyText1: TextStyle(color: Colors.black54),
//           ),
//         ),
//         initialRoute: 'welcome_screen',
//         routes: {
//           'welcome_screen': (context) => WelcomeScreen(),
//           'login_screen': (context) => LoginScreen(),
//           'registration_screen': (context) => RegistrationScreen(),
//           'chat_screen': (context) => ChatScreen(),
//           'search_screen': (context) => SearchScreen(),
//           'friends_screen': (context) => FriendsScreen(),
//           'profile_screen': (context) => ProfileScreen(),
//           'home_screen': (context) => HomeScreen(),
//         });
//   }
// }

Future<void> main() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  runApp(MaterialApp(home : email == null ? WelcomeScreen() : FriendsScreen()));
}