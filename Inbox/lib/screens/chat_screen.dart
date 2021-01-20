import 'package:Inbox/components/message_bubble.dart';
import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/models/message.dart';
// import 'package:dio/dio.dart';
import 'package:Inbox/models/constant.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();

  final String userId;
  final String username;
  final String avatar;
  ChatScreen({this.userId, this.username, this.avatar});
}

setCurrentChatScreen(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('path', 'chat_screen');
  prefs.setString("current_user_on_screen", username);
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();

    getUserData();
    

    setIsSeen();
  }

  

  final messageTextController = TextEditingController();
  var tokens;
  final SendNotification notificationData = SendNotification();
  final user = FirebaseAuth.instance.currentUser;
  final sendersMessageRefs = FirebaseFirestore.instance;
  final receiverMessageRefs = FirebaseFirestore.instance;
  final messageCollectionRefs = FirebaseFirestore.instance;
  final DateTime timeStamp = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isMute;
  bool isBlocked = false;
  bool isLoaded = false;
  bool isSending = false;
  bool isReceiverBlocked = false;
  List friendsList = [];
  String uniqueMessageId;
  String avatar;
  bool isSeen = false;
  String lastMessage;
  String username;

  setIsSeen() async {
    if (isInternet) {
      await FirebaseFirestore.instance
          .collection('users/' + user.uid + '/friends')
          .doc(widget.userId)
          .update({
        'isSeen': true,
      });
    }
  }

  bool isInternet = true;

  Future<bool> _onWillPop() async {
    if (isLoaded && isInternet) {
      if (friendsList.contains(widget.userId)) {
        FirebaseFirestore.instance
            .collection('users/' + user.uid + '/friends')
            .doc(widget.userId)
            .update({
          'isSeen': true,
        });

        return true;
      }
    }
    return true;
  }

  getUserData() async {
    final senderCollectionRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    friendsList = senderCollectionRef['friendsList'];
    avatar = senderCollectionRef['avtar'];
    username = senderCollectionRef['username'];
    final senderMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .get();
    lastMessage = senderMessageRefs['lastMessage'];
    final receiverBlocked = senderMessageRefs['isBlocked'];
    uniqueMessageId = senderMessageRefs['messageCollectionId'];
    final receiverMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/friends')
        .doc(user.uid)
        .get();
    final block = receiverMessageRefs['isBlocked'];
    isMute = receiverMessageRefs['isMuted'];
    // my user name means the name of current sender
    isSeen = receiverMessageRefs['isSeen'];
    tokens = await notificationData.getToken(widget.userId);
    print(tokens);

    setCurrentChatScreen(widget.username);
    if (block) {
      setState(() {
        isBlocked = true;
      });
    }
    if (isSeen) {
      setState(() {
        isSeen = true;
      });
    }
    if (!isSeen) {
      setState(() {
        isSeen = false;
      });
    }
    setState(() {
      isLoaded = true;
    });
    setState(() {
      if (receiverBlocked) {
        isReceiverBlocked = true;
      }
    });
  }

  showdialog(parentContext) async {
    // flutter defined function
    return showDialog(
      context: parentContext,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Error",
            style: TextStyle(color: Colors.red, fontFamily: 'Mulish'),
          ),
          content: Text(
            "Unable to send Message may you are blocked or not friends anymore !!",
            style: TextStyle(
                color: Colors.grey[700], fontFamily: 'Mulish', fontSize: 14),
          ),
          actions: <Widget>[
            FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.grey[800], fontFamily: 'Mulish'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String message;

  messageStream() {
    return StreamBuilder(
      stream: messageCollectionRefs
          .collection('messages/$uniqueMessageId/conversation')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message['message'];
            final messageSender = message['sender'];
            final timeStamp = message['timestamp'];
            final messageId = message['messageId'];
            final visibility = message['visibility'];
            // print(visibility);

            String time = '';

            DateTime d = timeStamp.toDate();
            final String dateTOstring = d.toString();

            for (int i = 11; i <= 15; i++) {
              time = time + dateTOstring[i];
            }

            final messageBubble = MessageBubble(
              timestamp: d,
              lastMessage: lastMessage,
              senderId: user.uid,
              receiverId: widget.userId,
              myMessageId: messageId,
              message: messageText,
              sender: user.uid == messageSender, //bool checking is sender;
              time: time,
              visibility: visibility,
              uniqueMessageId: uniqueMessageId,
              // avatar: widget.avatar
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

  sendMessage(String message, {List<Asset> assets = const []}) async {
    final messageDoc = await messageCollectionRefs
        .collection('messages/$uniqueMessageId/conversation')
        .add({
      'sender': user.uid,
      'message': message,
      'timestamp': DateTime.now(),
      'messageId': '',
      'assets': assets,
      'visibility': true,
      'avatar': avatar,
    });
    final String messageId = messageDoc.id;
    await messageCollectionRefs
        .collection('messages/$uniqueMessageId/conversation')
        .doc(messageId)
        .update({
      'messageId': messageId,
    });
    sendersMessageRefs
        .collection('users/' + widget.userId + '/friends')
        .doc(user.uid)
        .update({
      'messageAt': DateTime.now(),
      'lastMessage': message,
      'isSeen': false,
    });
    sendersMessageRefs
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .update({
      'messageAt': DateTime.now(),
      'lastMessage': message,
      'isSeen': true,
    });
    await sendersMessageRefs
        .collection(
            'users/' + user.uid + '/friends/' + widget.userId + '/messages')
        .doc(messageId)
        .set({
      'messageId': messageId,
      'timestamp': DateTime.now(),
    });
  }

  void onAddAssetClick() {}

  bodyToBuild() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: isReceiverBlocked
          ? Center(
              child: Text('Unblock the user to send messages..',
                  style: TextStyle(color: Colors.white)),
            )
          : Column(
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
                      ),
                  ],
                ),
                isBlocked
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('You cannot send message ! ' +
                            widget.username +
                            ' has blocked you'),
                      )
                    : Padding(
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
                            prefixIcon: IconButton(
                              splashRadius: 8,
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
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
                                String trimLeft =
                                    messageTextController.text.trimLeft();
                                String trimRight = trimLeft.trimRight();
                                message = trimRight;
                                setState(() {
                                  isSending = true;
                                });
                                if (message != null && message != '') {
                                  getUserData();
                                  if (isBlocked == false &&
                                      isReceiverBlocked == false &&
                                      friendsList.contains(widget.userId)) {
                                    setState(() {
                                      isSending = true;
                                    });
//Sender Collections

                                    messageTextController.clear();

                                    await sendMessage(message);
                                    

                                    message = '';
                                    setState(() {
                                      isSending = false;
                                    });
                                    await notificationData.sendOtherNotification(
                                      '$username',
                                      user.uid,
                                      widget.userId,
                                      message,
                                      'Private Message',
                                      tag: user.uid,
                                      isMuted: isMute,
                                      tokens: tokens,
                                    );
                                  } else {
                                    showdialog(context);
                                  }
                                } else {
                                  setState(() {
                                    isSending = false;
                                  });
                                }
                              },
                            ),
                            focusColor: Colors.grey[900],
                            filled: true,
                            fillColor: Colors.grey[900],
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide.none),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                borderSide: BorderSide.none),
                            hintText: 'Send Message',
                            hintStyle: TextStyle(
                                color: Colors.grey[100],
                                fontSize: 12.0,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  void choiceAction(String choice) {
    if (choice == DropDownMenu.muteChat) {
//print('clear chat');
      muteChat();
    } else if (choice == DropDownMenu.block) {
      blockUser();
    } else if (choice == DropDownMenu.unBlock) {
      unBlockUser();
    } else if (choice == DropDownMenu.unMute) {
      unMuteChat();
    }
  }

  unMuteChat() async {
    await FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/friends')
        .doc(user.uid)
        .update({
      'isMute': false,
    });
    setState(() {
      isMute = false;
    });
  }

  blockUser() async {
    await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .update({
      'isBlocked': true,
    });
    final senderMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .get();
    final receiverBlocked = senderMessageRefs['isBlocked'];
    setState(() {
      if (receiverBlocked) {
        isReceiverBlocked = true;
      }
    });
    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.redAccent,
      content: Text('User is blocked',
          style: TextStyle(
            color: Colors.white,
          )),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  unBlockUser() async {
    await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .update({
      'isBlocked': false,
    });
    final senderMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .get();
    final receiverBlocked = senderMessageRefs['isBlocked'];
    setState(() {
      if (!receiverBlocked) {
        isReceiverBlocked = false;
      }
    });
    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.redAccent,
      content: Text('User is unblocked',
          style: TextStyle(
            color: Colors.white,
          )),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  muteChat() async {
    await FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/friends')
        .doc(user.uid)
        .update({
      'isMute': true,
    });
    setState(() {
      isMute = true;
    });
  }

  appbarActionButton() {
    return <Widget>[
      PopupMenuButton<String>(
        onSelected: choiceAction,
        itemBuilder: (BuildContext context) {
          if (isReceiverBlocked && !isMute) {
            return DropDownMenu.blockedChoice.map((String choice) {
              return PopupMenuItem(value: choice, child: Text(choice));
            }).toList();
          } else if (!isReceiverBlocked && isMute) {
            return DropDownMenu.unMuteChoice.map((String choice) {
              return PopupMenuItem(value: choice, child: Text(choice));
            }).toList();
          } else if (isReceiverBlocked && isMute) {
            return DropDownMenu.bothBlockedAndMuted.map((String choice) {
              return PopupMenuItem(value: choice, child: Text(choice));
            }).toList();
          } else {
            return DropDownMenu.choices.map((String choice) {
              return PopupMenuItem(value: choice, child: Text(choice));
            }).toList();
          }
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xff111111),
        appBar: AppBar(
          elevation: 5,
          backgroundColor: Colors.black,
          actions: appbarActionButton(),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: widget.userId),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        backgroundImage:
                            widget.avatar == '' || widget.avatar == null
                                ? AssetImage('assets/images/user.png')
                                : CachedNetworkImageProvider(widget.avatar))),
                Text(
                  widget.username,
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
        body: isLoaded
            ? bodyToBuild()
            : Center(
                child: CircularProgressIndicator(),
              ),
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
