import 'package:Inbox/models/user.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';


class OthersProfile extends StatefulWidget {
  @override
  _OthersProfileState createState() => _OthersProfileState();
  final String profileId;
  OthersProfile({ this.profileId });
}

class _OthersProfileState extends State<OthersProfile> with TickerProviderStateMixin{
 
  final _auth = FirebaseAuth.instance;
  final userRefs = FirebaseFirestore.instance.collection('users');
  Animation animation;
  AnimationController controller;
   @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(microseconds: 200),vsync: this);

    animation = ColorTween(begin: Colors.grey[200], end : Colors.white).animate(controller);
    controller.forward();
   

  }

   buildProfileHeader(){
     return FutureBuilder(
      future: userRefs.doc(widget.profileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return SizedBox(
            height: 500,
            child: Center(
              child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 150.0),
          SkeletonAnimation(
                          child: CircleAvatar(
                radius: 50.0,
                backgroundColor: animation.value,
                backgroundImage: AssetImage('assets/images/profile-user.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonAnimation(
                              child: Text('                       ',
                style: TextStyle(
                  backgroundColor: animation.value,
                  color: Colors.black,
                  fontSize: 24.0,
                  fontFamily: 'Montserrat',
                ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 FlatButton(
                   color: animation.value,

                    splashColor: Colors.grey[400],
                    onPressed: () {
                       
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(color: Colors.grey[50], width: 2),
                    ), 
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      child: Text("                         ",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat'
                      ),
                      ),
                    ),  
                  ),
              //   FlatButton(
              //       splashColor: Colors.grey[400],
              //       color: animation.value,
              //       onPressed: () {
                       
              //       },
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(4.0),
              //         side: BorderSide(color: Colors.grey[50], width: 2),
              //       ), 
              //       child: Padding(
              //         padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              //         child: Text("           ",
              //         style: TextStyle(
              //           color: animation.value,
              //           fontFamily: 'Montserrat'
              //         ),
              //         ),
              //       ),  
              //     ),
               ],
            ),
              SizedBox(height : 20.0),
              SkeletonAnimation(
                              child: Text(
                  '                                      ',
                  style: TextStyle(
                    backgroundColor: animation.value,
                    color: Colors.grey,
                    fontFamily: 'Mulish',
                    fontSize: 16.0
                  ),
                ),
              ),
              SizedBox(height : 20.0),
              SkeletonAnimation(
                              child: Text(
                  '                               ',
                  style: TextStyle(
                    backgroundColor: animation.value,
                    color: Colors.black54,
                    fontFamily: 'Mulish',
                    fontSize: 16.0
                  ),
                ),
              ),
              
          ],
        )
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
                   color: Colors.blue[900],
                    splashColor: Colors.blue[600],
                    onPressed: () {
                       
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(color: Colors.blue[900], width: 2),
                    ), 
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Text("Send Friend Request",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat'
                      ),
                      ),
                    ),  
                  ),
                // FlatButton(
                //     splashColor: Colors.grey[400],
                //     onPressed: () {
                       
                //     },
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(4.0),
                //       side: BorderSide(color: Colors.grey[50], width: 2),
                //     ), 
                //     child: Padding(
                //       padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                //       child: Text("Following",
                //       style: TextStyle(
                //         color: Colors.indigo,
                //         fontFamily: 'Montserrat'
                //       ),
                //       ),
                //     ),  
                //   ),
              ],
            ),
            // SizedBox(height : 20.0),
            //   Text(
            //     user.email == '' ? 'Email: Add your email....' : user.email,
            //     style: TextStyle(
            //       color: Colors.black54,
            //       fontFamily: 'Mulish',
            //       fontSize: 16.0
            //     ),
            //   ),
              SizedBox(height : 40.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, right: 32),
                  child: Text(
                    user.bio == '' ? user.username +' has not provided bio yet' : user.bio,
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Mulish',
                      fontSize: 18.0
                    ),
                  ),
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
        
        title: Text('Profile',
        style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.grey[900],
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //     child: IconButton(
        //       splashRadius: 16.0,
        //       onPressed: () {
        //       Navigator.pop(context);

        //     },
        //         icon: Icon(Icons.close),
        //   ))
        // ],
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