import 'package:Inbox/components/friends_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  List friendsList = [];
  List groupList = [];

  bool isDataLoaded = false;
  bool isEmptyFriendList = false;
  bool isEmptyGroupList = false;

  getUsersFriendData() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    friendsList = userAccountRefs['friendsList'];
    setState(() {
      isDataLoaded = true;
    });
    if (friendsList.isNotEmpty) {
      setState(() {
        isEmptyFriendList = false;
      });
    } else if (friendsList.isEmpty) {
      setState(() {
        isEmptyFriendList = true;
      });
    }
  }


  buildNocontentForChats() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isEmptyFriendList ? Text('') : CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            Center(
                child: isEmptyFriendList
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

  buildNoContentScreenForGroups(){
    return Center(
      child: Column(
        mainAxisAlignment : MainAxisAlignment.center,
        children : [
          Container(
            color : Colors.black,
            child: Icon(Icons.add,color: Colors.white))
        ]
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
                  key: Key(userid['userId']),
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

  groupListStream() {
    return Center(child: Text('Groups are shown here'),);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
          child: Scaffold(
        appBar: AppBar(
          title: Text('Inbox', style: TextStyle(fontFamily: 'Montserrat')),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey[900],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text('Chats',style: TextStyle(fontFamily: 'Mulish',fontSize: 15)),
              ),
              Tab(child: Text('Groups',style: TextStyle(fontFamily: 'Mulish',fontSize: 15)),)
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body : TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
          isDataLoaded && !isEmptyFriendList
            ? friendsListStream()
            : buildNocontentForChats(),
            buildNoContentScreenForGroups(),
          //  isDataLoaded && !isEmptyGroupList
          //   ? groupListStream()
          //   : buildNoContentScreenForGroups(),
          
        ],)
      ),
    );
  }
}
