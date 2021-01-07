// import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:Inbox/screens/home.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
// import 'package:Inbox/screens/notification_screen.dart';
// import 'package:Inbox/screens/profile_screen.dart';
// import 'package:Inbox/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:data_connection_checker/data_connection_checker.dart';
//import 'package:flutter_svg/flutter_svg.dart';
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
    //checkInternet();
    getUsersFriendData();
  }

  final _collectionRefs = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser.uid;
  List friendsList;

  bool isDataLoaded = false;
  bool isEmpty = false;
  //bool isInternet = true;

  getUsersFriendData() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    friendsList = userAccountRefs['friendsList'];
    setState(() {
      isDataLoaded = true;
    });
    if (friendsList.isNotEmpty) {
      setState(() {
        isEmpty = false;
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

  // checkInternet() async {
  //   bool result = await DataConnectionChecker().hasConnection;
  //   if (result == true) {
  //     setState(() {
  //       isInternet = true;
  //     });
  //   } else {
  //     setState(() {
  //       isInternet = false;
  //     });
  //   }
  // }

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
            .orderBy('messageAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final userIds = snapshot.data.documents;
            List<FriendsTile> friendsWidget = [];
            for (var userid in userIds) {
              final sendersUsername = userid['username'];
              final sendersUserId = userid['userId'];
              final isSeen = userid['isSeen'];
              final message = userid['lastMessage'];
              String lastMessage = '';
              if (message.length > 50) {
                for (int i = 0; i <= 50; i++) {
                  lastMessage = lastMessage + message[i];
                }
              } else {
                lastMessage = message;
              }

              final frndWidget = FriendsTile(
                  sendersUserId: sendersUserId,
                  sendersUsername: sendersUsername,
                  isSeen: isSeen,
                  lastMessage: lastMessage);
              friendsWidget.add(frndWidget);
              friendsWidget.reversed;
            }
            return ListView(physics: BouncingScrollPhysics(), children: [
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
      body: isDataLoaded && !isEmpty
          ? friendsListStream()
          : buildNoContentScreen(),
    );
  }
}

class FriendsTile extends StatefulWidget {
  final String sendersUserId;
  final bool isSeen;
  final String sendersUsername;
  final String lastMessage;

  FriendsTile(
      {this.sendersUsername,
      this.isSeen,
      this.sendersUserId,
      this.lastMessage});

  @override
  _FriendsTileState createState() => _FriendsTileState();
}

class _FriendsTileState extends State<FriendsTile> {


  @override
  initState(){
  super.initState();
  getUserAvatr();
  }


  bool isDataLoaded = false;
  String avatar;



  getUserAvatr() async {
    final _data = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.sendersUserId)
        .get();
    avatar = _data['avtar'];
    setState(() {
      isDataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              showChatScreen(context, profileId: widget.sendersUserId);
            },
            child: ListTile(
              leading: isDataLoaded
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 32,
                      backgroundImage: avatar == null || avatar == ''
                          ? AssetImage('assets/images/profile-user.png')
                          : CachedNetworkImageProvider(avatar),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 32,
                      backgroundImage:
                          AssetImage('assets/images/profile-user.png'),
                    ),
              trailing: !widget.isSeen
                  ? Icon(
                      Icons.fiber_manual_record,
                      color: Colors.blue[900],
                      size: 12,
                    )
                  : Icon(Icons.fiber_manual_record, color: Colors.grey[50]),
              title: Text(widget.sendersUsername,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Monstserrat')),
              subtitle: Text(widget.lastMessage,
                  style: !widget.isSeen
                      ? TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )
                      : TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        )),
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
