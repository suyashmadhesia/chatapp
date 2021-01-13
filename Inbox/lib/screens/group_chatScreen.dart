import 'package:Inbox/components/group_message_bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupBanner;
  GroupChatScreen({
    this.groupId,
    this.groupName,
    this.groupBanner,
  });

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  initState() {
    super.initState();
    getUserData();
  }

//Variables
  String message;
  String myUsername;
  final messageTextController = TextEditingController();
  final userid = FirebaseAuth.instance.currentUser.uid;
  final collectionRefs = FirebaseFirestore.instance;
  final DateTime timeStamp = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSending = false;
  bool isDataLoaded = false;
  List groupsList = [];
  bool isAbleToSendMessage = false;
  var joinedAt;
  bool admin = false;

  messageStream() {
    return StreamBuilder(
      stream: collectionRefs
          .collection('groups/' + widget.groupId + '/messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final messages = snapshot.data.documents.reversed;
          List<GroupMessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message['message'];
            final usernameOfSender = message['usernameOfSender'];
            final messageId = message['messageId'];
            final timeStamp = message['timestamp'];
            final visibility = message['visibility'];
            final senderUserId = message['senderUserId'];

            String time = '';
            DateTime d = timeStamp.toDate();
            final String dateTOstring = d.toString();

            for (int i = 11; i <= 15; i++) {
              time = time + dateTOstring[i];
            }

            final messageBubble = GroupMessageBubble(
              message: messageText,
              messageId: messageId,
              sender: userid == senderUserId,
              timestamp: d,
              time: time,
              visibility: visibility,
              usernameOfSender: usernameOfSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              reverse: true,
              children: messageBubbles,
            ),
          );
        }
      },
    );
  }

  appbarActions() {
    return Container(
      child: Row(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff484848),
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          if (admin)
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                )),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
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
          messageStream(),
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
                  onPressed: () async {
                    String trimLeft = messageTextController.text.trimLeft();
                    String trimRight = trimLeft.trimRight();
                    message = trimRight;
                    if (message != null && message != "") {
                      getUserData();
                      if (isAbleToSendMessage) {
                        // debugPrint('in user group List');
                        messageTextController.clear();
                        setState(() {
                          isSending = true;
                        });
                        await sendMessage(message);
                        setState(() {
                          isSending = false;
                        });
                        message = '';
                      }
                    }
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

  sendMessage(String message) async {
    String messageId = Uuid().v4();
    await collectionRefs
        .collection('groups/' + widget.groupId + '/messages')
        .doc(messageId)
        .set({
      'message': message,
      'usernameOfSender': myUsername,
      'assets': [],
      'messageId': messageId,
      'senderUserId': userid,
      'timestamp': DateTime.now(),
      'visibility': true,
    });
    collectionRefs.collection('groups').doc(widget.groupId).update({
      'lastMessage': message,
    });
    await collectionRefs
        .collection('users/$userid/groups/' + widget.groupId + '/messages')
        .doc(messageId)
        .set({
      'messageAt': DateTime.now(),
      'messageId': messageId,
    });
  }

  getUserData() async {
    final userData = await collectionRefs.collection('users').doc(userid).get();
    groupsList = userData['groupsList'];
    myUsername = userData['username'];

    final groupMemberData = await collectionRefs
        .collection('groups/' + widget.groupId + '/members')
        .doc(userid)
        .get();
    joinedAt = groupMemberData['joinAt'];
    bool isAdmin = groupMemberData['isAdmin'];

    if (groupsList.contains(widget.groupId)) {
      setState(() {
        isAbleToSendMessage = true;
      });
    }
    if (isAdmin) {
      setState(() {
        admin = true;
      });
    }
    if (!isAdmin) {
      setState(() {
        admin = false;
      });
    }

    setState(() {
      isDataLoaded = true;
    });
  }
}
