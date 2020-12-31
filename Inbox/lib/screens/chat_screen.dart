//import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/models/constant.dart';
import 'package:Inbox/screens/profile_other.dart';
//import 'package:Inbox/screens/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focused_menu/modals.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:focused_menu/focused_menu.dart';

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
    setIsSeen();
  }

  final messageTextController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final userid = FirebaseAuth.instance.currentUser.uid;
  final sendersMessageRefs = FirebaseFirestore.instance;
  final receiverMessageRefs = FirebaseFirestore.instance;
  final DateTime timeStamp = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String username;
  String profileLink;
  bool isBlocked = false;
  bool isLoaded = false;
  bool isSending = false;
  bool isReceiverBlocked = false;
  
  setIsSeen() async {
	  final senderMessageRefs = await FirebaseFirestore.instance.collection('users/$userid/friends').doc(widget.userId).update({
	  'isSeen' : true,
	});

  }

  getUserData() async {
    final senderMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .get();
    final receiverBlocked = senderMessageRefs['isBlocked'];
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
    setState(() {
      if (receiverBlocked) {
        isReceiverBlocked = true;
      }
    });
  }

  AppBar buildNocontentBar() {
    return AppBar(
      backgroundColor: Colors.grey[900],
      title: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 14),
              child: SkeletonAnimation(
                child: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  radius: 20,
                ),
              )),
          SkeletonAnimation(
            child: Text(
              '                       ',
              style: TextStyle(
                backgroundColor: Colors.grey[800],
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
          .orderBy('timestamp', descending: false)
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
            final timeStamp = messag['timestamp'];
            final myMessageId = messag['id'];
            final messageId = messag['anotherId'];

            String day = '';
            String time = '';

            DateTime d = timeStamp.toDate();
            final String dateTOstring = d.toString();

            for (int i = 5; i <= 10; i++) {
              day = day + dateTOstring[i];
            }
            for (int i = 11; i <= 15; i++) {
              time = time + dateTOstring[i];
            }

            final messageBubble = MessageBubble(
              senderId: user.uid,
              receiverId: widget.userId,
              myMessageId: myMessageId,
              ontherId: messageId,
              message: messageText,
              sender: userid == messageSender,
              time: time,
              // messageId: messageId,
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

  bodyToBuild() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: isReceiverBlocked
          ? Center(
              child: Text('Unblock the user to send messages..',style: TextStyle(color : Colors.white)),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                messageStream(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    isSending
                        ? Text(
                            'Sending  ',
                            style: TextStyle(
                                fontSize: 10.0,
                                color: Colors.grey[400],
                                fontFamily: 'Montserrat'),
                          )
                        : Text(''),
                  ],
                ),
                isBlocked
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            'You cannot send message ! $username has blocked you'),
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
                                  if (isBlocked == false &&
                                      isReceiverBlocked == false) {
                                    setState(() {
                                      isSending = true;
                                    });
//Sender Collections
                                    final senderMessageCollection =
                                        await sendersMessageRefs
                                            .collection('users/' +
                                                widget.userId +
                                                '/friends/' +
                                                user.uid +
                                                '/messages')
                                            .add({
                                      'sender': user.uid,
                                      'message': message,
                                      'timestamp': DateTime.now(),
                                      'id': '',
                                      'anotherId': '',
                                    });
                                    final String docid =
                                        senderMessageCollection.id;

                                    await sendersMessageRefs
                                        .collection('users/' +
                                            widget.userId +
                                            '/friends')
                                        .doc(user.uid)
                                        .update({
                                      'messageAt': DateTime.now(),
                                    });
//Receiver Collections
                                    await FirebaseFirestore.instance.collection('users/'+widget.userId+'/friends').doc(user.uid).update({
				    'isSeen' : false,
				    });
				    final receieverMessageCollection =
                                        await sendersMessageRefs
                                            .collection('users/' +
                                                user.uid +
                                                '/friends/' +
                                                widget.userId +
                                                '/messages')
                                            .add({
                                      'sender': user.uid,
                                      'message': message,
                                      'timestamp': DateTime.now(),
                                      'id': '',
                                      'anotherId': '',
                                    });
                                    final String docId =
                                        receieverMessageCollection.id;

                                    await sendersMessageRefs
                                        .collection(
                                            'users/' + user.uid + '/friends')
                                        .doc(widget.userId)
                                        .update({
                                      'messageAt': DateTime.now(),
                                    });
                                    //userCollection of message id
                                    await sendersMessageRefs
                                        .collection('users/' +
                                            widget.userId +
                                            '/friends/' +
                                            user.uid +
                                            '/messages')
                                        .doc(docid)
                                        .update({
                                      'id': docid,
                                      'anotherId': docId,
                                    });
                                    await sendersMessageRefs
                                        .collection('users/' +
                                            user.uid +
                                            '/friends/' +
                                            widget.userId +
                                            '/messages')
                                        .doc(docId)
                                        .update({
                                      'id': docId,
                                      'anotherId': docid,
                                    });
                                    setState(() {
                                      isSending = false;
                                    });
                                  }
                                }
                              },
                            ),
                            focusColor: Colors.grey[900],
                            filled: true,
                            fillColor: Colors.grey[900],
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide.none),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
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

  void choiceAction(String choice) {
    if (choice == DropDownMenu.clearChat) {
      print('clear chat');
      clearChat();
    } else if (choice == DropDownMenu.block) {
      blockUser();
    } else if (choice == DropDownMenu.unBlock) {
      unBlockUser();
    }
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
    final receiverMessageRefs = await FirebaseFirestore.instance
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

  clearChat() async {
    await FirebaseFirestore.instance
        .collection(
            'users/' + user.uid + '/friends/' + widget.userId + '/messages')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  appbarActionButton() {
    return <Widget>[
      PopupMenuButton<String>(
        onSelected: choiceAction,
        itemBuilder: (BuildContext context) {
          return isReceiverBlocked
              ? DropDownMenu.blockedChoice.map((String choice) {
                  return PopupMenuItem(value: choice, child: Text(choice));
                }).toList()
              : DropDownMenu.choices.map((String choice) {
                  return PopupMenuItem(value: choice, child: Text(choice));
                }).toList();
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xff484848),
        appBar: isLoaded
            ? AppBar(
                backgroundColor: Colors.grey[900],
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
                              backgroundImage: profileLink == '' ||
                                      profileLink == null
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
                ),
              )
            : buildNocontentBar(),
        body: isLoaded
            ? bodyToBuild()
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool sender;
  final String time;
  final String myMessageId;
  final String ontherId;
  final String senderId;
  final String receiverId;

  MessageBubble({
    this.message,
    this.sender,
    this.time,
    this.myMessageId,
    this.ontherId,
    this.senderId,
    this.receiverId,
  });

  //Function
  unsendMessage() async {
    final receiverCollectionRef = FirebaseFirestore.instance
        .collection('users/' + receiverId + '/friends/$senderId/messages');
    await receiverCollectionRef.doc(ontherId).delete();
    final senderCollectionRef = FirebaseFirestore.instance
        .collection('users/$senderId/friends/$receiverId/messages');
    await senderCollectionRef.doc(myMessageId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 12, bottom: 4, left: 8),
      child: Column(
        crossAxisAlignment:
            sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!sender)
            Text(
              time,
              style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 8,
                  fontFamily: 'Montserrat'),
            ),
          Padding(
            padding: sender
                ? EdgeInsets.only(left: screenWidth * 0.2)
                : EdgeInsets.only(right: screenWidth * 0.2),
            child: Material(
              elevation: 5,
              borderRadius: sender
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(32),
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
              color: sender
                  ? Colors.purple[800]
                  : Colors.grey[500], //Color(0xff5ddef4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: sender
                    ? FocusedMenuHolder(
                        menuItemExtent:
                            MediaQuery.of(context).size.height * 0.06,
                        blurBackgroundColor: Colors.grey[600],
                        blurSize: 0,
                        menuWidth: MediaQuery.of(context).size.width * 0.3,
                        duration: Duration(milliseconds: 50),
                        onPressed: () {},
                        menuItems: <FocusedMenuItem>[
                          FocusedMenuItem(
                              title: Text(
                                'Unsend',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                await unsendMessage();
                              },
                              backgroundColor: Colors.redAccent,
                              trailingIcon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ))
                        ],
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Montserrat'),
                        ),
                      )
                    : Text(
                        message,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Montserrat'),
                      ),
              ),
            ),
          ),
          if (sender)
            Text(
              time,
              style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 8,
                  fontFamily: 'Montserrat'),
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
