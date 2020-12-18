import 'package:Inbox/screens/edit_profile.dart';
//import 'package:Inbox/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:Inbox/screens/search_screen.dart';
import 'package:Inbox/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Inbox/models/user.dart';


class ProfileScreen extends StatefulWidget {
  
  final String profileId;
  ProfileScreen({ this.profileId });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final userRefs = FirebaseFirestore.instance.collection('users');


//Functions
   buildProfileHeader(){
     return FutureBuilder(
      future: userRefs.doc(widget.profileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return SizedBox(
            height: 500,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[400],
              ),
            ),
          );
        }
        Account user = Account.fromDocument(snapshot.data);
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 150.0),
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.grey[100],
              backgroundImage: user.avtar == '' ? AssetImage('assets/images/profile-user.png') : CachedNetworkImageProvider(user.avtar),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(user.username,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontFamily: 'Montserrat',
              ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 FlatButton(

                    splashColor: Colors.grey[400],
                    onPressed: () {
                       
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(color: Colors.grey[50], width: 2),
                    ), 
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      child: Text("Followers",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontFamily: 'Montserrat'
                      ),
                      ),
                    ),  
                  ),
                FlatButton(
                    splashColor: Colors.grey[400],
                    onPressed: () {
                       
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(color: Colors.grey[50], width: 2),
                    ), 
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      child: Text("Following",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontFamily: 'Montserrat'
                      ),
                      ),
                    ),  
                  ),
              ],
            ),
              SizedBox(height : 20.0),
              Text(
                user.bio == '' ? 'Bio : Write something about you....' : user.bio,
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Mulish',
                  fontSize: 16.0
                ),
              ),
              SizedBox(height : 20.0),
              Text(
                user.email == '' ? 'Email: Add your email....' : user.email,
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Mulish',
                  fontSize: 16.0
                ),
              ),
              
          ],
        );
      },
    );
  }
    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfileScreen()));},
        icon: Icon(Icons.edit,color: Colors.white),
        ),
        title: Text('Profile',
        style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              splashRadius: 16.0,
              onPressed: () async{
              _auth.signOut();
              final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
              sharedPreferences.remove(
              'email');
              Navigator.popUntil(context, ModalRoute.withName('login_screen'));
              Firebase.initializeApp().whenComplete(() {
              print('initialization Complete');
              setState(() {});
            });
              Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));

            },
                icon: Icon(Icons.logout)),
          )
        ],
        ),
      body: SafeArea(
        child: Center(
          child: ListView( 
            physics: BouncingScrollPhysics(),
            children: [
              buildProfileHeader(),
            ],
          ),
        ),
      ),
    );
  }
}
