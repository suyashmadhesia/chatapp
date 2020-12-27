import 'package:Inbox/reusable/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/models/user.dart';
// import 'package:Inbox/screens/home.dart';
import 'package:Inbox/screens/profile_other.dart';
// import 'package:Inbox/screens/profile_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:Inbox/screens/friends_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeleton_text/skeleton_text.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _collectionRefs = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser.uid;
  List pendingList = [];

  @override
  initState() {
    super.initState();
    getUsersFriendData();
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
              return Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
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
              );
            } else if (snapshot.hasData) {
              final userIds = snapshot.data.documents;
              List<Widget> notificationWidget = [];
              for (var userid in userIds) {
                final sendersUsername = userid['SendersUsername'];
                final sendersUserId = userid['pendingUserId'];
                final senderAvatar = userid['SendersAvatar'];
                final notificationCard = Container(
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          showProfile(context, profileId: sendersUserId);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 32,
                              backgroundImage: senderAvatar == '' || senderAvatar == null ?
                                  AssetImage('assets/images/profile-user.png')
                                  : CachedNetworkImageProvider(senderAvatar)),
                          title: Text(
                              sendersUsername +
                                  ' sent you friend request tap to accept or reject',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
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
                notificationWidget.add(notificationCard);
                notificationWidget.reversed;
              }
              return ListView(
                              children: [Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: notificationWidget,
                ),]
              );
            } else {
              return Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Colors.grey[500],
                    height: 2.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: ListTile(
                      leading: SkeletonAnimation(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 32,
                        ),
                      ),
                      title: SkeletonAnimation(
                        child: Text('                             ',
                            style: TextStyle(
                                backgroundColor: Colors.grey[200],
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Monstserrat')),
                      ),
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
              );
            }
         
        });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 20.0,
          ),
        ),
      ),
      body: empty ? buildNoContentScreen() : notficationStream(),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OthersProfile(
        profileId: profileId,
      ),
    ),
  );
}
