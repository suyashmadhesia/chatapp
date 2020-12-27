// import 'package:firebase_core/firebase_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeleton_text/skeleton_text.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();

  final String userId;
  ChatScreen({this.userId});
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  final messageTextController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final userid = FirebaseAuth.instance.currentUser.uid;
  final sendersMessageRefs = FirebaseFirestore.instance;
  final receiverMessageRefs = FirebaseFirestore.instance;

  String username;
  String profileLink;
  bool isBlocked = false;
  bool isLoaded = false;

  getUserData() async {
    final receiverAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    username = receiverAccountRefs['username'];
    profileLink = receiverAccountRefs['avtar'];
    // if user is not blocked
    final receiverMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/friends')
        .doc(user.uid)
        .get();
    final block = receiverMessageRefs['isBlocked'];
    if (block) {
      setState(() {
        isBlocked = true;
      });
    }
    setState(() {
      isLoaded = true;
    });
  }

  AppBar buildNocontentBar() {
    return AppBar(
      title: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 14),
              child: SkeletonAnimation(
                child: CircleAvatar(
                  backgroundColor: Colors.grey[500],
                  radius: 20,
                ),
              )),
          SkeletonAnimation(
            child: Text(
              '                       ',
              style: TextStyle(
                backgroundColor: Colors.grey[500],
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String message;

  messageStream() {
    return StreamBuilder(
      stream: sendersMessageRefs
          .collection(
              'users/' + user.uid + '/friends/' + widget.userId + '/messages')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final message = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var messag in message) {
            final messageText = messag['message'];
            final messageSender = messag['sender'];

            final messageBubble =
                MessageBubble(message: messageText, sender: userid == messageSender);
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

  bodyToBuild() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          messageStream(),
          isBlocked
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'You can not send message ! $username has blocked you'),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, bottom: 4, top: 12),
                  child: TextField(
                    controller: messageTextController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 50,
                    onChanged: (value) {
                      message = value;
                    },
                    cursorColor: Colors.grey[100],
                    autofocus: false,
                    style: TextStyle(
                        height: 1,
                        fontSize: 14.0,
                        color: Colors.grey[100],
                        fontFamily: 'Montserrat'),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        splashRadius: 8,
                        icon: Icon(
                          Icons.send,
                          color: Colors.green[400],
                        ),
                        onPressed: () async {
                          if (message != null || message != '') {
                            messageTextController.clear();
                            if (isBlocked == false) {
                              await sendersMessageRefs
                                  .collection('users/' +
                                      widget.userId +
                                      '/friends/' +
                                      user.uid +
                                      '/messages')
                                  .add({
                                'sender': user.uid,
                                'message': message,
                              });
                              await sendersMessageRefs
                                  .collection('users/' +
                                      user.uid +
                                      '/friends/' +
                                      widget.userId +
                                      '/messages')
                                  .add({
                                'sender': user.uid,
                                'message': message,
                              });
                            }
                          }
                        },
                      ),
                      focusColor: Colors.grey[900],
                      filled: true,
                      fillColor: Colors.grey[900],
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none),
                      hintText: ' Send Message...',
                      hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.0,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff323232),
      appBar: isLoaded
          ? AppBar(
              backgroundColor: Colors.grey[900],
              title: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          backgroundImage:
                              profileLink == '' || profileLink == null
                                  ? AssetImage('assets/images/profile-user.png')
                                  : CachedNetworkImageProvider(profileLink))),
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            )
          : buildNocontentBar(),
      body: bodyToBuild(),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool sender;

  MessageBubble({this.message, this.sender});
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5,
            borderRadius: sender ? BorderRadius.only(bottomLeft: Radius.circular(32),
            topLeft: Radius.circular(32) ,
            topRight: Radius.circular(32),
            ) : BorderRadius.only(topRight: Radius.circular(32),
            bottomLeft: Radius.circular(32) ,
            bottomRight: Radius.circular(32),
            ),
            color: sender ? Colors.deepPurple[700] : Color(0xff353b4f),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                message,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
