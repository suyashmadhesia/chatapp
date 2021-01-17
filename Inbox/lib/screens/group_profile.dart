import 'package:Inbox/components/screen_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupProfileScreen extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String groupBanner;
  final String groupDescription;
  final List groupMembers;
  final List groupAdmin;

  GroupProfileScreen(
      {this.groupName,
      this.groupBanner,
      this.groupId,
      this.groupAdmin,
      this.groupDescription,
      this.groupMembers});

  @override
  _GroupProfileScreenState createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  //variables
  double screenHeight;
  double screenWidth;
  final userId = FirebaseAuth.instance.currentUser.uid;
  bool isJoined;
  bool request;
  bool leave;
  bool isDataLoaded;

  //functions
  loadGroupBanner(double height, double width) {
    if (widget.groupBanner.isEmpty || widget.groupBanner == null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: DecorationImage(
            image: AssetImage('assets/images/group.png'),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      Container(
        height: height,
        width: width,
        child: Image.network(widget.groupBanner),
      );
    }
  }

  getUserData() async{

  }

  checkJoined(){

  }

  checkInvitation(){

  }

  checkRequest(){

  }

  createJoinButton() {

  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                loadGroupBanner(screenH * 0.4, screenW),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      
                      widget.groupName,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                          fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.white,
              elevation: 5,
              child: ListTile(
                tileColor: Colors.white,
                title: Text(
                  'Description',
                  style: TextStyle(
                      color: Colors.green[900],
                      fontFamily: 'Montserrat',
                      fontSize: 14),
                ),
                subtitle: Text(
                  widget.groupDescription,
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16),
                ),
              ),
            ),
            SizedBox(
              height: screenWidth * 2,
            ),
            Material(
              elevation: 5,
              child: ListTile(
                tileColor: Colors.white,
                title: Text(
                  'Total Members',
                  style: TextStyle(
                      color: Colors.green[900],
                      fontFamily: 'Montserrat',
                      fontSize: 14),
                ),
                subtitle: Text(
                  widget.groupMembers.length.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// appBar: AppBar(
//         elevation: 0,
//         title: Text(widget.groupName,
//             style: TextStyle(fontFamily: 'Montserrat', color: Colors.black)),
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () {
//               Navigator.pop(context);
//             }),
//         backgroundColor: Colors.white,
//       ),
