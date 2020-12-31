import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/friends_screen.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:Inbox/screens/search_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'notification_screen.dart';

// final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');

// final DateTime timestamp = DateTime.now();
// User currentUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      //print('initialization Complete');
      setState(() {});
    });
    getUserData();
    pageController = PageController();
  }

  User user = FirebaseAuth.instance.currentUser;

  // getUserInfo() async {
  //   DocumentSnapshot doc = await usersRef.doc(user.uid).get();
  //   currentUser = User.fromDocument(doc);
  // }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(
      pageIndex,
    );
    getUserData();
  }

  List userPendingList;
  bool showNotification = false;

  getUserData() async {
    final userAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    userPendingList = userAccountRefs['pendingList'];
    if(userPendingList.isNotEmpty){
      setState(() {
        showNotification = true;
      });
    }
    else{
      setState(() {
        showNotification = false;
      });
    }
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          FriendsScreen(),
          SearchScreen(),
          NotificationScreen(),
          ProfileScreen(profileId: user?.uid),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: Duration(milliseconds: 400),
        color: Colors.grey[900],
        backgroundColor: Colors.white,
        height: 50,
        items: <Widget>[
          Icon(
            Icons.favorite_rounded,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.search,
            size: 20,
            color: Colors.white,
          ),
          Stack(
            children: [
              Icon(
                Icons.notifications,
                size: 20,
                color: Colors.white,
              ),
              showNotification ?
              Container(
                width: 6,
                height: 6,
                 decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
              border: Border.all(color: Colors.redAccent, width: 1))
              ) : Container(
                width : 4,
                height : 4,
                color : Colors.grey[900]
              ),
            ],
          ),
          Icon(
            Icons.person,
            size: 20,
            color: Colors.white,
          ),
        ],
        // animationDuration: Duration(milliseconds: 200),

        // animationCurve: Curves.bounceInOut,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildAuthScreen();
  }
}

// Widget build(BuildContext context){
//   return Scaffold(
//     backgroundColor: Colors.red,
//   );
//   }
// }
