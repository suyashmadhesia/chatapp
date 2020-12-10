// import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/friends_screen.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:Inbox/screens/search_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

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
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          SearchScreen(),
          FriendsScreen(),
          ProfileScreen(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.grey[900],
        backgroundColor: Colors.white,
        height: 50,
        items: <Widget>[
          Icon(
          Icons.search,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.favorite_rounded,
            size: 25,
            color: Colors.white,
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
