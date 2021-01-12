import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupBanner;
  final String myUsername;
  GroupChatScreen({this.groupId, this.groupName, this.groupBanner, this.myUsername});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {

  initState(){
    super.initState();
    getUserData();
  }

//Variables
  String message;
  final messageTextController = TextEditingController();
  final userid = FirebaseAuth.instance.currentUser.uid;
  final collectionRefs = FirebaseFirestore.instance;
  final DateTime timeStamp = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSending = false;
  bool isDataLoaded = false;
  List groupsList = [];
  bool isAbleToSendMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff484848),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  backgroundImage:
                      widget.groupBanner == '' || widget.groupBanner == null
                          ? AssetImage('assets/images/user.png')
                          : CachedNetworkImageProvider(widget.groupBanner),
                ),
              ),
              Text(
                widget.groupName,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: isDataLoaded
          ? bodyToBuild()
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  bodyToBuild() {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // messageStream(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isSending)
                Text(
                  'Sending ...',
                  style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey[400],
                      fontFamily: 'Montserrat'),
                )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, bottom: 10, top: 10),
            child: TextField(
              controller: messageTextController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 50,
              cursorColor: Colors.grey[100],
              autofocus: false,
              style: TextStyle(
                  height: 1,
                  fontSize: 14.0,
                  color: Colors.grey[100],
                  fontFamily: 'Montserrat'),
              decoration: InputDecoration(
                focusColor: Colors.grey[900],
                filled: true,
                fillColor: Colors.grey[900],
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide.none),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    borderSide: BorderSide.none),
                hintText: 'Send Message',
                hintStyle: TextStyle(
                    color: Colors.grey[100],
                    fontSize: 12.0,
                    fontFamily: 'Montserrat'),
                prefixIcon: IconButton(
                  splashRadius: 8,
                  icon: Icon(Icons.add),
                  onPressed: () {
                    onAddAssetClick();
                  },
                ),
                suffixIcon: IconButton(
                  splashRadius: 8,
                  icon: Icon(
                    Icons.send,
                    color: Colors.green[400],
                  ),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  onAddAssetClick() {}

  sendMessage() async{
    String messageId = Uuid().v4();
    await collectionRefs.collection('groups/'+widget.groupId).doc(messageId).set({
      'message' : message,
      'usernameOfSender' : widget.myUsername,
      'assets': [],
      'messageId' : messageId,
      'senderUserId' : userid,
      'timestamp' : DateTime.now(),
      'visibility' : true,
    });
    await collectionRefs.collection('users/$userid/groups/'+widget.groupId+'messages').doc(messageId).set({
      'messageAt': DateTime.now(),
      'messageId': messageId,
    });
  }

  messageStream() {}

  getUserData() async {
    final userData = await collectionRefs.collection('users').doc(userid).get();
    groupsList = userData['groupsList'];

    if (groupsList.contains(widget.groupId)) {
      setState(() {
        isAbleToSendMessage = true;
      });
    }

    setState(() {
      isDataLoaded = true;
    });
  }
}
