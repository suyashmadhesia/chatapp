import 'package:Inbox/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsTile extends StatefulWidget {
  final String sendersUserId;
  final bool isSeen;
  final String sendersUsername;
  final String lastMessage;
  final Key key;

  FriendsTile(
      {this.sendersUsername,
      this.isSeen,
      this.key,
      this.sendersUserId,
      this.lastMessage});

  @override
  _FriendsTileState createState() => _FriendsTileState();
}

class _FriendsTileState extends State<FriendsTile> {
  @override
  initState() {
    super.initState();
    getUserAvatr();
  }

  bool isDataLoaded = false;
  String avatar;

  getUserAvatr() async {
    final _data = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.sendersUserId)
        .get();
    avatar = _data['avtar'];
    setState(() {
      isDataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              showChatScreen(context, profileId: widget.sendersUserId);
            },
            child: ListTile(
              leading: isDataLoaded
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 32,
                      backgroundImage: avatar == null || avatar == ''
                          ? AssetImage('assets/images/profile-user.png')
                          : CachedNetworkImageProvider(avatar),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 32,
                      backgroundImage:
                          AssetImage('assets/images/profile-user.png'),
                    ),
              trailing: !widget.isSeen
                  ? Icon(
                      Icons.fiber_manual_record,
                      color: Colors.blue[900],
                      size: 12,
                    )
                  : Icon(Icons.fiber_manual_record, color: Colors.grey[50]),
              title: Text(widget.sendersUsername,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Monstserrat')),
              subtitle: Text(widget.lastMessage,
                  style: !widget.isSeen
                      ? TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )
                      : TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        )),
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

showChatScreen(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        userId: profileId,
      ),
    ),
  );
}