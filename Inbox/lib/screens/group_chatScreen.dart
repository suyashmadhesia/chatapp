import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupBanner;
  GroupChatScreen({this.groupId, this.groupName, this.groupBanner});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
//Variables
  String message;
  final messageTextController = TextEditingController();
  final userid = FirebaseAuth.instance.currentUser.uid;
  final sendersMessageRefs = FirebaseFirestore.instance;
  final receiverMessageRefs = FirebaseFirestore.instance;
  final DateTime timeStamp = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSending = false;

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
      body: bodyToBuild(),
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

  sendMessage(){}

  messageStream() {}
}
