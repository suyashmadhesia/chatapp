// import 'dart:io';

import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/models/constant.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

// import 'package:uuid/uuid.dart';

class GroupDashboard extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;
  final String groupBanner;
  final bool isAdmin;

  GroupDashboard(this.isAdmin,
      {this.groupId, this.groupName, this.groupBanner, this.groupDescription});

  @override
  _GroupDashboardState createState() => _GroupDashboardState();
}

class _GroupDashboardState extends State<GroupDashboard> {
  //Variables
  double screenHeight;
  double screenWidth;
  final collectionRefs = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser.uid;
  bool isDataLoaded = false;
  List adminsList = [];
  List membersList = [];
  bool admin = false;

  @override
  initState() {
    super.initState();
    getGroupData();
    print(userId);
  }

  getGroupData() async {
    final groupData = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .get();
    adminsList = groupData['adminsId'];
    membersList = groupData['groupMember'];
    setState(() {
      isDataLoaded = true;
    });
    if (adminsList.contains(userId)) {
      setState(() {
        admin = true;
      });
    }
  }

  loadGroupBanner(double height, double width) {
    if (widget.groupBanner.isEmpty || widget.groupBanner == null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: DecorationImage(
            image: AssetImage('assets/images/user.png'),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return Container(
        height: height,
        width: width,
        child: Image.network(widget.groupBanner),
      );
    }
  }

  removeFromGroup(String userId) async {
    await collectionRefs.collection('groups').doc(widget.groupId).update({
      'groupMember': FieldValue.arrayRemove([userId]),
    });
    await collectionRefs.collection('users').doc(userId).update({
      'groupsList': FieldValue.arrayRemove([widget.groupId]),
    });
    await collectionRefs
        .collection('groups/' + widget.groupId + '/members')
        .doc(userId)
        .delete();
    await collectionRefs
        .collection('users/' + userId + '/groups')
        .doc(widget.groupId)
        .delete();
  }

  upgradeToAdmin(String userID) async {
    if (adminsList.length < 4) {
      await collectionRefs
          .collection('groups/' + widget.groupId + '/members')
          .doc(userID)
          .update({
        'isAdmin': true,
      });
      await collectionRefs.collection('groups').doc(widget.groupId).update({
        'adminsId': FieldValue.arrayUnion([userID]),
      });
    } else {
      print('error');
    }
  }

  groupMember() {
    return StreamBuilder(
      stream: collectionRefs
          .collection('groups/' + widget.groupId + '/members')
          .orderBy('joinAt', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final groupMembers = snapshot.data.documents;
          List<Widget> memberWidgetList = [];
          for (var member in groupMembers) {
            final username = member['username'];
            // final joinAt = member['joinAt'];
            final memberId = member['userId'];
            final isAdmin = member['isAdmin'];
            if (memberId != FirebaseAuth.instance.currentUser.uid) {
              print('I am WOrking');
              final memberWidget = Container(
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OthersProfile(profileId: memberId)));
                  },
                  child: ListTile(
                    title: Text(
                      username,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Monstserrat'),
                    ),
                    trailing: isAdmin
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.teal[500],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                'Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontFamily: 'Monstserrat'),
                              ),
                            ))
                        : null,
                    subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (admin && !isAdmin)
                            FlatButton(
                              color: Colors.green,
                              onPressed: () async {
                                bool buttonLoading = false;
                                if (!buttonLoading) {
                                  setState(() {
                                    buttonLoading = true;
                                  });
                                  await getGroupData();
                                  await upgradeToAdmin(memberId);

                                  setState(() {
                                    buttonLoading = false;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  'Create Admin',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontFamily: 'Monstserrat'),
                                ),
                              ),
                            ),
                          if (admin && !isAdmin)
                            FlatButton(
                              color: Colors.green,
                              onPressed: () async {
                                bool buttonLoading = false;
                                if (!buttonLoading) {
                                  setState(() {
                                    buttonLoading = true;
                                  });
                                  await getGroupData();
                                  await removeFromGroup(memberId);
                                  setState(() {
                                    buttonLoading = false;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Text(
                                  'Remove',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontFamily: 'Monstserrat'),
                                ),
                              ),
                            ),
                        ]),
                  ),
                ),
              );
              memberWidgetList.add(memberWidget);
            }
            return Column(
              children: memberWidgetList,
            );
          }
        }
      },
    );
  }

  // void choiceAction(String choice){
  //   if(choice == DropDownMenu.createAdmin){
  //     upgradeToAdmin(String userID);
  //   }
  // }

  // actionButton(){
  //   return <Widget>[
  //     PopupMenuButton<String>(
  //       onSelected: choiceAction,
  //       itemBuilder: (BuildContext context){
  //         return DropDownMenu.groupAction.map((String choice){
  //           return PopupMenuItem(value: choice,child:Text(choice));
  //         }).toList();
  //       },

  //     )
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return isDataLoaded
        ? Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              physics: BouncingScrollPhysics(),
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
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                      'Members',
                      style: TextStyle(
                          color: Colors.green[900],
                          fontFamily: 'Montserrat',
                          fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenWidth * 2,
                ),
                groupMember(),
              ],
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()));
  }
}
