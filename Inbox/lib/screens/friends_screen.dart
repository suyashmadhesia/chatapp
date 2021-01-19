import 'package:Inbox/components/friends_card.dart';
import 'package:Inbox/components/group_card.dart';
import 'package:Inbox/components/loading_skeleton.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/send_notification.dart';
// import 'package:Inbox/screens/group_chatScreen.dart';
// import 'package:Inbox/screens/group_profile.dart';
import 'package:Inbox/screens/notification_screen.dart';
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
  List pendingList = [];

  bool isDataLoaded = false;
  bool showNotification = false;
  bool isEmptyFriendList = false;
  bool isEmptyGroupList = false;
  String myUsername;
  getUsersFriendData() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    friendsList = userAccountRefs['friendsList'];
    pendingList = userAccountRefs['pendingList'];
    groupList = userAccountRefs['groupsList'];
    myUsername = userAccountRefs['username'];

    setState(() {
      isDataLoaded = true;
    });
    groupList.forEach((value) {
      SendNotification().topicToSuscribe('/topics/' + value);
    });
    if (groupList.isEmpty) {
      setState(() {
        isEmptyGroupList = true;
      });
    }
    if (groupList.isNotEmpty) {
      setState(() {
        isEmptyGroupList = false;
      });
    }
    if (friendsList.isNotEmpty) {
      setState(() {
        isEmptyFriendList = false;
      });
    } else if (friendsList.isEmpty) {
      setState(() {
        isEmptyFriendList = true;
      });
    }
    if (pendingList.isNotEmpty) {
      setState(() {
        showNotification = true;
      });
    } else {
      setState(() {
        showNotification = false;
      });
    }
  }

  floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateGroup(username: myUsername)));
      },
      elevation: 5,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.add,
        color: Colors.pink[400],
      ),
    );
  }

  //build no content screen for the chats tab
  buildNocontentForChats() {
    return isEmptyFriendList
        ? Center(
            child: Text('No friends Yet !!',
                style: TextStyle(
                    color: Colors.grey, fontSize: 16, fontFamily: 'Mulish')))
        : LoadingContainer();
  }

  // build no content screen for group tab
  buildNoContentScreenForGroups() {
    return isEmptyGroupList
        ? Center(
            child: Text('Not in any group !!',
                style: TextStyle(
                    color: Colors.grey, fontSize: 16, fontFamily: 'Mulish')))
        : LoadingContainer();
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
            return Center(child: LoadingContainer());
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
    return StreamBuilder(
        stream: _collectionRefs
            .collection('groups')
            .orderBy('messageAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: LoadingContainer());
          } else if (snapshot.hasData) {
            final groupIds = snapshot.data.documents;
            List<GroupCard> groupsWidget = [];
            for (var groupid in groupIds) {
              final groupName = groupid['groupName'];
              final groupBanner = groupid['groupBanner'];
              final groupId = groupid['groupId'];
              final groupMembers = groupid['groupMember'];
              final messageAt = groupid['messageAt'];
              final lastMessage = groupid['lastMessage'];
              final groupDescription = groupid['groupDescription'];
              final adminsList = groupid['adminsId'];
              DateTime dateTime = messageAt.toDate();

              if (groupMembers.contains(_userId)) {
                final GroupCard groupWidget = GroupCard(
                  groupName: groupName,
                  groupBanner: groupBanner,
                  groupId: groupId,
                  lastMessage: lastMessage,
                  messageAt: dateTime,
                  userId: _userId,
                  key: Key(groupId),
                  username: myUsername,
                  membersList: groupMembers,
                  groupDescription: groupDescription,
                  adminList: adminsList,
                );
                groupsWidget.add(groupWidget);
                groupsWidget.reversed;
              }
            }
            return ListView(physics: BouncingScrollPhysics(), children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: groupsWidget,
              ),
            ]);
          }
        });
  }

  double screenHeight;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                        //  builder: (context) => GroupProfileScreen(),
                      ),
                    );
                  },
                ),
                if (showNotification)
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 3),
                    child: Container(
                        width: screenWidth * 1.7,
                        height: screenWidth * 1.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 1),
                          color: Colors.red,
                        )
                        // borderRadius: BorderRadius.circular(8)),

                        ),
                  ),
              ],
            ),
          )
        ],
        toolbarHeight: screenHeight * 170,
        elevation: 0,
        title: Text('Inbox',
            style: TextStyle(
                fontFamily: 'Mulish', color: Colors.black, fontSize: 32)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.grey[200],
          tabs: [
            Tab(
              child: Text('Chats',
                  style: TextStyle(
                      fontFamily: 'Mulish', fontSize: 15, color: Colors.black)),
            ),
            Tab(
              child: Text('Groups',
                  style: TextStyle(
                      fontFamily: 'Mulish', fontSize: 15, color: Colors.black)),
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
          isDataLoaded && !isEmptyGroupList
              ? groupListStream()
              : buildNoContentScreenForGroups(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? floatingActionButton()
          : null, //checking whether we are on chat tab or group tab
    );
  }
}
