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
    );
  }
}
