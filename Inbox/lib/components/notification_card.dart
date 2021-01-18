import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/send_notification.dart';
// import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatefulWidget {
  final String username;
  final String id; //sendersUserId userId
  final String time;
  final String avatar;
  final requestType;
  final DateTime timeStamp;
  final String userId; //my userId,
  final String target;
  final String targetId;

  NotificationCard(
      {this.avatar,
      this.targetId,
      this.time,
      this.id,
      this.username,
      this.requestType,
      this.timeStamp,
      this.userId,
      this.target});

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  
  final collectionRefs = FirebaseFirestore.instance;

  List adminsList = [];

  joinGroup() async {
    await collectionRefs.collection('groups').doc(widget.id).update({
      'groupMember': FieldValue.arrayUnion([widget.userId]),
    });
    await collectionRefs
        .collection('groups/' + widget.id + '/members')
        .doc(widget.userId)
        .set({
      'joinAt': DateTime.now(),
      'isAdmin': false,
      'userId': widget.userId,
      'username': widget.username,
    });
    await collectionRefs.collection('users').doc(widget.userId).update({
      'groupsList': FieldValue.arrayUnion([widget.id]),
      'pendingList': FieldValue.arrayRemove([widget.id]),
    });
    await collectionRefs
        .collection('users/' + widget.userId + '/groups')
        .doc(widget.id)
        .set({
      'joinedAt': DateTime.now(),
      'isMuted': false,
      'groupName': widget.username,
      'isAdmin': false,
      'messageAt': DateTime.now(),
      'groupId': widget.id,
    });
    final receiverCollectionRef = FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/pendingRequests');
    await receiverCollectionRef.doc(widget.id).delete();
    SendNotification().topicToSuscribe('/topics/' + widget.id);
  }

  rejectInvitation() async {
    await collectionRefs.collection('users').doc(widget.userId).update({
      'pendingList': FieldValue.arrayRemove([widget.id]),
    });
    final receiverCollectionRef = FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/pendingRequests');
    await receiverCollectionRef.doc(widget.id).delete();
  }

  joinOrRejectButton() {
    if (widget.requestType == 'GroupRequestFromGroup') {
      bool isLoading = false;
      return isLoading
          ? Center(
              child: SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2)))
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FlatButton(
                  color: Colors.grey,
                  onPressed: () async {
                    if (!isLoading) {
                      setState(() {
                        isLoading = true;
                      });
                      await joinGroup();
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Join',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Monstserrat'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FlatButton(
                    color: Colors.grey[200],
                    onPressed: () async {
                      if (!isLoading) {
                        setState(() {
                          isLoading = true;
                        });
                        await rejectInvitation();
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontFamily: 'Monstserrat'),
                      ),
                    ),
                  ),
                ),
              ],
            );
    }else if (widget.requestType == 'GroupJoiningFromUser'){
      bool isLoading = false;
      return isLoading
          ? Center(
              child: SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(strokeWidth: 2)))
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FlatButton(
                  color: Colors.grey,
                  onPressed: () async {
                    if (!isLoading) {
                      setState(() {
                        isLoading = true;
                      });
                      await acceptRequest();
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Monstserrat'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FlatButton(
                    color: Colors.grey[200],
                    onPressed: () async {
                      if (!isLoading) {
                        setState(() {
                          isLoading = true;
                        });
                        await cancelRequest();
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontFamily: 'Monstserrat'),
                      ),
                    ),
                  ),
                ),
              ],
            );
    }
  }

  acceptRequest() async {
    final groupAdmin =
        await collectionRefs.collection('groups').doc(widget.targetId).get();
    adminsList = groupAdmin['adminsId'];
    if (adminsList.length == 1) {
      await collectionRefs.collection('users').doc(adminsList[0]).update({
        'pendingList': FieldValue.arrayRemove([widget.id]),
      });
      final sendDataToAdmin = collectionRefs
          .collection('users/' + adminsList[0] + '/pendingRequests');
      await sendDataToAdmin.doc(widget.id).delete();
    } else {
      for (int i = 0; i <= adminsList.length; i++) {
        await collectionRefs.collection('users').doc(adminsList[i]).update({
          'pendingList': FieldValue.arrayRemove([widget.id]),
        });
        final sendDataToAdmin = collectionRefs
            .collection('users/' + adminsList[i] + '/pendingRequests');
        await sendDataToAdmin.doc(widget.id).delete();
      }
    }

    await collectionRefs.collection('groups').doc(widget.targetId).update({
      'groupMember': FieldValue.arrayUnion([widget.id]),
    });
    await collectionRefs
        .collection('groups/' + widget.targetId + '/members')
        .doc(widget.id)
        .set({
      'joinAt': DateTime.now(),
      'isAdmin': false,
      'userId': widget.id,
      'username': widget.username,
    });
    await collectionRefs.collection('users').doc(widget.id).update({
      'groupsList': FieldValue.arrayUnion([widget.targetId]),
      'requestList': FieldValue.arrayRemove([widget.targetId]),
    });
    await collectionRefs
        .collection('users/' + widget.targetId + '/groups')
        .doc(widget.targetId)
        .set({
      'joinedAt': DateTime.now(),
      'isMuted': false,
      'groupName': widget.target,
      'isAdmin': false,
      'messageAt': DateTime.now(),
      'groupId': widget.targetId,
    });
  }

  cancelRequest() async{
    await collectionRefs.collection('users').doc(widget.userId).update({
      'pendingList': FieldValue.arrayRemove([widget.id]),
    });
    final receiverCollectionRef = FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/pendingRequests');
    await receiverCollectionRef.doc(widget.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    double screenHeight = screenSize.dividingHeight();
    return widget.requestType == 'GroupJoiningFromUser'
        ? Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    String group = '';
                    for (int i = 0; i <= 5; i++) {
                      group = group + widget.id[i];
                    }
                    if (group == 'GROUP') {}
                    showProfile(context, profileId: widget.id);
                  },
                  child: ListTile(
                    subtitle: joinOrRejectButton(),
                    leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: screenHeight * 42,
                        backgroundImage:
                            widget.avatar == '' || widget.avatar == null
                                ? AssetImage('assets/images/user.png')
                                : CachedNetworkImageProvider(widget.avatar)),
                    title: Text(
                        widget.username +
                            ' sent you request to join your ' +
                            widget.target +
                            ' group',
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
          )
        : Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: () {
                    String group = '';
                    for (int i = 0; i <= 5; i++) {
                      group = group + widget.id[i];
                    }
                    if (group == 'GROUP') {}
                    showProfile(context, profileId: widget.id);
                  },
                  child: ListTile(
                    subtitle: joinOrRejectButton(),
                    leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: screenHeight * 42,
                        backgroundImage:
                            widget.avatar == '' || widget.avatar == null
                                ? AssetImage('assets/images/user.png')
                                : CachedNetworkImageProvider(widget.avatar)),
                    title: Text(
                        widget.requestType == 'GroupRequestFromGroup'
                            ? widget.username + ' group sent you invitation !!'
                            : widget.username +
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
