import 'package:Inbox/components/friends_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'create_group.dart';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  @override
  initState() {
    super.initState();
    getUsersFriendData();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  //Listening wihich tab is currently open
  void handleTabIndex() {
    setState(() {});
  }

  //TabCOntroller for controlling tab view;
  TabController _tabController;
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

  floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateGroup()));
      },
      elevation: 5,
      backgroundColor: Colors.grey[900],
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  //build no content screen for the chats tab
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

  // build no content screen for group tab
  buildNoContentScreenForGroups() {
    return Center(
      child: Text('hello world'),
    );
  }

  //TODO: UPDATE friends list stream
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

  //group list stream
  groupListStream() {
    return Center(
      child: Text('Groups are shown here'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox', style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Text('Chats',
                  style: TextStyle(fontFamily: 'Mulish', fontSize: 15)),
            ),
            Tab(
              child: Text('Groups',
                  style: TextStyle(fontFamily: 'Mulish', fontSize: 15)),
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        physics: BouncingScrollPhysics(),
        children: [
          isDataLoaded && !isEmptyFriendList
              ? friendsListStream()
              : buildNocontentForChats(),
          buildNoContentScreenForGroups(),
          //  isDataLoaded && !isEmptyGroupList
          //   ? groupListStream()
          //   : buildNoContentScreenForGroups(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? floatingActionButton()
          : null, //checking whether we are on chat tab or group tab
    );
  }
}
