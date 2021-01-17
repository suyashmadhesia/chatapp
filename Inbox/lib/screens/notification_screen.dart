//import 'package:Inbox/reusable/components.dart';
import 'package:Inbox/components/notification_card.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:Inbox/models/user.dart';
// import 'package:Inbox/screens/home.dart';
// import 'package:Inbox/screens/profile_other.dart';
// import 'package:Inbox/screens/profile_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:Inbox/screens/friends_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:skeleton_text/skeleton_text.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _collectionRefs = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser.uid;
  List pendingList;

  void setCurrentScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("path", "");
    prefs.setString("current_user_on_screen", "");
  }

  @override
  initState() {
    super.initState();
    getUsersFriendData();
    setCurrentScreen();
  }

  bool empty = true;
  getUsersFriendData() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    pendingList = userAccountRefs['pendingList'];
    if (pendingList.isNotEmpty) {
      setState(() {
        empty = false;
      });
    }
  }

  buildNoContentScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/notification.svg',
                height: 200, width: 200),
            Center(
                child: Text('No notification yet.....',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Mulish'))),
          ],
        ),
      ),
    );
  }

  notficationStream() {
    return StreamBuilder(
        stream: _collectionRefs
            .collection('users/$_userId/pendingRequests')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else if (snapshot.hasData) {
            final userIds = snapshot.data.documents;
            List<NotificationCard> notificationWidget = [];
            for (var userid in userIds) {
              final sendersUsername = userid['SendersUsername'];
              final sendersUserId = userid['pendingUserId'];
              final senderAvatar = userid['SendersAvatar'];
              final requestType = userid['requestType'];
              final timeStamp = userid['sendAt'];
              final targetName = userid['targetName'];

              String time = '';

              DateTime d = timeStamp.toDate();
              final String dateTOstring = d.toString();

              for (int i = 11; i <= 15; i++) {
                time = time + dateTOstring[i];
              }

              final notificationCard = NotificationCard(
                avatar: senderAvatar,
                requestType: requestType,
                timeStamp: d,
                id: sendersUserId,
                username: sendersUsername,
                time: time,
                userId: _userId,
                target: targetName,
              );
              notificationWidget.add(notificationCard);
              notificationWidget.reversed;
            }
            return ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: notificationWidget,
              ),
            ]);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  double screenHeight;
  double screenWidth;
  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
         leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: (){
                Navigator.pop(context);
              }),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontSize: 20.0,
          ),
        ),
      ),
      body: empty ? buildNoContentScreen() : notficationStream(),
    );
  }
}
