import 'package:Inbox/models/user.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OthersProfile extends StatefulWidget {
  @override
  _OthersProfileState createState() => _OthersProfileState();
}

class _OthersProfileState extends State<OthersProfile> {
 
  final _auth = FirebaseAuth.instance;
  final userRefs = FirebaseFirestore.instance.collection('users');

   buildProfileHeader(){
     return FutureBuilder(
      future: userRefs.doc().get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[400],
              ),
            ),
          );
        }
        Account user = Account.fromDocument(snapshot.data);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150.0),
              CircleAvatar(
                radius: 50.0,
                backgroundColor: Colors.white,
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
                  Buttons(buttonName: 'Follow', onPressed: (){}), 
                ],
              ),
                SizedBox(height : 20.0),
                Text(
                  user.bio == '' ? 'Bio : No bio is given...' : user.bio,
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Mulish',
                    fontSize: 16.0
                  ),
                ),
                               
            ],
          ),
        );
      },
    );
   }
    
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        
        title: Text('Profile',
        style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              splashRadius: 16.0,
              onPressed: () {
              Navigator.pop(context);

            },
                icon: Icon(Icons.done),
          ))
        ],
        ),
      body: SafeArea(
        child: ListView( 
          physics: BouncingScrollPhysics(),
          children: [
            buildProfileHeader(),
          ],
        ),
      ),
    );
  }


}