import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/send_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  initState() {
    super.initState();
    getUserData();
    checkStatus();
  }

  //variables
  double screenHeight;
  double screenWidth;
  final collectionRefs = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser.uid;
  bool showAcceptButton = false;
  bool showCancelButton = false;
  bool showLeaveButton = false;
  bool showRequestButton = false;
  bool isDataLoaded = false;
  List groupList;
  List pendingList;
  List requestList;
  bool loadingButton = false;
  String username;
  String avatar;
  final SendNotification notificationData = SendNotification();

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

  getUserData() async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    pendingList = userData['pendingList'];
    groupList = userData['groupsList'];
    requestList = userData['requestList'];
    username = userData['username'];
    avatar = userData['avtar'];
    setState(() {
      isDataLoaded = true;
    });
  }

  checkStatus() {
    if (pendingList.contains(
            widget.groupId) && //create accept button and cancel button,
        !groupList.contains(widget.groupId) &&
        !requestList.contains(widget.groupId)) {
      setState(() {
        showAcceptButton = true;
        showCancelButton = false;
        showLeaveButton = false;
        showRequestButton = false;
      });
    } else if (!pendingList.contains(widget.groupId) && //create request button
        !groupList.contains(widget.groupId) &&
        !requestList.contains(widget.groupId)) {
      setState(() {
        showAcceptButton = false;
        showCancelButton = false;
        showLeaveButton = false;
        showRequestButton = true;
      });
    } else if (!pendingList.contains(widget.groupId) && //create leave button
        groupList.contains(widget.groupId) &&
        !requestList.contains(widget.groupId)) {
      setState(() {
        showAcceptButton = false;
        showCancelButton = false;
        showLeaveButton = true;
        showRequestButton = false;
      });
    } else if (!pendingList.contains(widget.groupId) && //create cancel  button
        !groupList.contains(widget.groupId) &&
        requestList.contains(widget.groupId)) {
      setState(() {
        showAcceptButton = false;
        showCancelButton = true;
        showLeaveButton = false;
        showRequestButton = false;
      });
    }
  }

  flatButton(String data, Function onPressed, Color color) {
    return FlatButton(
      color: color,
      onPressed: loadingButton ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          data,
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
      ),
    );
  }

  acceptInvitation() async {
    await getUserData();
    setState(() {
      loadingButton = true;
    });
    if (pendingList.contains(
            widget.groupId) && //create accept button and cancel button,
        !groupList.contains(widget.groupId) &&
        !requestList.contains(widget.groupId)) {
      await collectionRefs.collection('users').doc(userId).update({
        'requestList': FieldValue.arrayRemove([widget.groupId]),
        'groupsList': FieldValue.arrayUnion([widget.groupId]),
      });
      await collectionRefs
          .collection('groups/' + widget.groupId + '/members')
          .doc(userId)
          .set({
        'joinAt': DateTime.now(),
        'isAdmin': false,
        'userId': userId,
        'username': username,
      });
      await collectionRefs
          .collection('users/' + userId + '/groups')
          .doc(widget.groupId)
          .set({
        'joinedAt': DateTime.now(),
        'isMuted': false,
        'groupName': widget.groupName,
        'isAdmin': false,
        'messageAt': DateTime.now(),
        'groupId': widget.groupId,
      });
      final receiverCollectionRef = FirebaseFirestore.instance
          .collection('users/' + userId + '/pendingRequests');
      await receiverCollectionRef.doc(widget.groupId).delete();
    }
    setState(() {
      loadingButton = false;
    });
  }

  rejectInvitation() async {
    await collectionRefs.collection('users').doc(userId).update({
      'pendingList': FieldValue.arrayRemove([widget.groupId]),
    });
    final receiverCollectionRef = FirebaseFirestore.instance
        .collection('users/' + userId + '/pendingRequests');
    await receiverCollectionRef.doc(widget.groupId).delete();
  }

  sendJoiningRequest() async {
    await getUserData();
    setState(() {
      loadingButton = true;
    });
    if (!pendingList.contains(widget.groupId) && //create request button
        !groupList.contains(widget.groupId) &&
        !requestList.contains(widget.groupId)) {
      await collectionRefs.collection('users').doc(userId).update({
        'requestList': FieldValue.arrayUnion([widget.groupId]),
      });
      for (int i = 0; i <= widget.groupAdmin.length; i++) {
        await collectionRefs
            .collection('users')
            .doc(widget.groupAdmin[i])
            .update({
          'pendingList': FieldValue.arrayUnion([userId]),
        });
        final sendDataToAdmin = collectionRefs
            .collection('users/' + widget.groupAdmin[i] + '/pendingRequests');
        await sendDataToAdmin.doc(userId).set({
          'pendingUserId': userId,
          'SendersUsername': username,
          'SenderAvatar': avatar,
          'requestType': 'GroupJoiningFromUser',
          'sendAt': DateTime.now(),
          'targetName' : widget.groupName,
        });
      }
    }
    setState(() {
      loadingButton = false;
    });
  }

  cancelJoiningRequest() async {
    await getUserData();
    setState(() {
      loadingButton = true;
    });
    if (!pendingList.contains(widget.groupId) && //create cancel  button
        !groupList.contains(widget.groupId) &&
        requestList.contains(widget.groupId)) {
      await collectionRefs.collection('users').doc(userId).update({
        'requestList': FieldValue.arrayRemove([widget.groupId]),
      });
      for (int i = 0; i <= widget.groupAdmin.length; i++) {
        await collectionRefs
            .collection('users')
            .doc(widget.groupAdmin[i])
            .update({
          'pendingList': FieldValue.arrayRemove([userId]),
        });
        final sendDataToAdmin = collectionRefs
            .collection('users/' + widget.groupAdmin[i] + '/pendingRequests');
        await sendDataToAdmin.doc(userId).delete();
      }
    }
    setState(() {
      loadingButton = false;
    });
  }

  leaveGroup() async {
    if (!widget.groupAdmin.contains(userId)) {
      await collectionRefs.collection('groups').doc(widget.groupId).update({
        'groupMember': FieldValue.arrayRemove([userId]),
      });
    }else{
      if(widget.groupAdmin.length < 2 && widget.groupMembers.length != 1){
        await collectionRefs
        .collection('groups/' + widget.groupId + '/members')
        .doc(widget.groupMembers[1])
        .update({
          'isAdmin' : true,
        });
        await collectionRefs.collection('groups').doc(widget.groupId).update({
        'groupMember': FieldValue.arrayRemove([userId]),
      });
        Navigator.pop(context);
      }
      else if(widget.groupMembers.length == 1){
        print('error');
      }
    }
  }

  createGroupInteractionButton() {
    if (showAcceptButton) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          flatButton('Join', acceptInvitation(), Colors.green),
          flatButton('Cancel', rejectInvitation(), Colors.redAccent),
        ],
      );
    } else if (showCancelButton) {
      return flatButton(
          'Cancel Request', cancelJoiningRequest(), Colors.redAccent);
    } else if (showLeaveButton) {
      flatButton('Leave', leaveGroup(), Colors.redAccent);
    } else if (showRequestButton) {
      return flatButton('Send Request', sendJoiningRequest(), Colors.purple);
    }
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
      body: isDataLoaded ? ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                SizedBox(
                  height: screenWidth * 2,
                ),
                loadingButton ? Center(child: CircularProgressIndicator(strokeWidth: 2,)) : createGroupInteractionButton(),
              ],
            ),
          ),
        ],
      ) : Center(child: CircularProgressIndicator()),
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
