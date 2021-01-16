import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/screens/group_chatScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  final String groupName;
  final String groupBanner;
  final String groupId;
  final DateTime messageAt;
  final String lastMessage;
  final String userId;
  final Key key;
  final String username;

  GroupCard(
      {this.groupName,
      this.userId,
      this.messageAt,
      this.lastMessage,
      this.groupBanner,
      this.groupId,
      this.key,
      this.username,
      });

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {

  initState(){
    super.initState();
    getUserData();
  }


  double screenHeight;
  double screenWidth;
  bool isDataLoaded = false;
  final collectionRefs = FirebaseFirestore.instance;
  DateTime joinedAt;

//Updating messageAT for cecking that message is seen or not
  updateSeen() async {
    final groupInUserCollection =
        collectionRefs.collection('users/' + widget.userId + '/groups');
    await groupInUserCollection.doc(widget.groupId).update({
      'messageAt': DateTime.now(),
    });
  }

  checkMessageSeen() {}

  getUserData() async {
    final groupInUserCollection =
      await collectionRefs.collection('users/' + widget.userId + '/groups').doc(widget.groupId).get();
      final joinAt = groupInUserCollection['joinedAt'];
      joinedAt = joinAt.toDate();
      setState(() {
        isDataLoaded = true;
      });

  }

  compare(){
    if(isDataLoaded){
      return widget.messageAt.isAfter(joinedAt);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: screenWidth * 1.1,
          ),
          GestureDetector(
            onTap: () {
              showGroupChat(context,
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  groupBanner: widget.groupBanner);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: screenHeight * 42,
                backgroundImage:
                    widget.groupBanner == null || widget.groupBanner == ''
                        ? AssetImage('assets/images/group.png')
                        : CachedNetworkImageProvider(widget.groupBanner),
              ),
              title: Text(
                widget.groupName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Monstserrat',
                ),
              ),
              subtitle: isDataLoaded
                  ? Text(
                      compare() ? widget.lastMessage : 'You have joined this group',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    )
                  : Text(
                      'Loading...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
         
        ],
      ),
    );
  }
}

showGroupChat(BuildContext context,
    {String groupId, String groupName, String groupBanner}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupChatScreen(
        groupId: groupId,
        groupName: groupName,
        groupBanner: groupBanner,
      ),
    ),
  );
}
