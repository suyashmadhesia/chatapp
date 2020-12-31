import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/chat_screen.dart';
import 'package:Inbox/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
// import 'package:Inbox/screens/notification_screen.dart';
// import 'package:Inbox/screens/profile_screen.dart';
// import 'package:Inbox/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:Inbox/reusable/components.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  initState() {
    super.initState();
    getUsersFriendData();
  }

  final _collectionRefs = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser.uid;
  List friendsList = [];

  bool isDataLoaded = true;
  bool isEmpty = false;

  getUsersFriendData() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    friendsList = userAccountRefs['friendsList'];
    if (friendsList.isNotEmpty) {
      setState(() {
        isDataLoaded = false;
      });
    } else if (friendsList.isEmpty) {
      setState(() {
        isEmpty = true;
      });
      // setState(() {
      //   isDataLoaded = false;
      // });
    }
  }
  

  buildNoContentScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isEmpty ? Text('') : CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            Center(
                child: isEmpty
                    ? Text('No friends to show....',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontFamily: 'Mulish'))
                    : Text('Wait while we loading .....',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontFamily: 'Mulish'))),
          ],
        ),
      ),
    );
  }

  friendsListStream() {
    return StreamBuilder(
        stream: _collectionRefs
            .collection('users/$_userId/friends')
            .orderBy('messageAt',descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            final userIds = snapshot.data.documents;
            List<Widget> friendsWidget = [];
            for (var userid in userIds) {
              final sendersUsername = userid['username'];
              final sendersUserId = userid['userId'];
	      final isSeen = userid['isSeen'];
              final frndWidget = Container(
                color: Colors.grey[50],
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        showChatScreen(context, profileId: sendersUserId);
                      },
                      child: ListTile(
			trailing: !isSeen ? Icon(Icons.fiber_manual_record, color: Colors.green,size: 12,):Icon(Icons.fiber_manual_record,color:Colors.grey[50]),
                        title: Text(sendersUsername,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(
                      color: Colors.grey[500],
                      height: 2.0,
                    )
                  ],
                ),
              );
              friendsWidget.add(frndWidget);
              friendsWidget.reversed;
            }
            return ListView(
			    physics: BouncingScrollPhysics(),
			    children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: friendsWidget,
              ),
            ]);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox', style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.white,
      body: isDataLoaded ? buildNoContentScreen() : friendsListStream(),
    );
  }
}

showChatScreen(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        userId: profileId,
      ),
    ),
  );
}
