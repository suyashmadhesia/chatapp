//import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/components/message_bubble.dart';
import 'package:dio/dio.dart';
import 'package:Inbox/models/constant.dart';
import 'package:Inbox/screens/profile_other.dart';
//import 'package:Inbox/screens/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/modals.dart';
// import 'package:skeleton_text/skeleton_text.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();

  final String userId;
  ChatScreen({this.userId});
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
    checkInternet();

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
  String rUsername;
  String profileLink;
  String receiversUserId;
  bool isBlocked = false;
  bool isLoaded = false;
  bool isSending = false;
  bool isReceiverBlocked = false;
  List friendsList = [];

  setIsSeen() async {
    if (isInternet) {
      final senderMessageRefs = await FirebaseFirestore.instance
          .collection('users/$userid/friends')
          .doc(widget.userId)
          .update({
        'isSeen': true,
      });
    }
  }

  Future<List> getToken(userId) async {
    final db = FirebaseFirestore.instance;

    var token;
    List listofTokens = [];
    await db.collection('users/' + userId + '/tokens').get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        token = doc.id;
        listofTokens.add(token);
      });
    });

    return listofTokens;
  }

  Future<void> sendNotification(
      receiver, message, username, receiversUserId) async {
    var token = await getToken(receiver);
    // debugPrint('token : $token');

    final data = {
      "notification": {"body": "$message", "title": "$username"},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "type": "Message",
        "userId": receiversUserId,
      },
      'registration_ids': token,
      "collapse_key": "$receiversUserId message",
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAdFdVbjo:APA91bGYkVTkUUKVcOk5O5jz2WZAwm8d1losRaJVEYKF5yspBahEWf-2oMhrnyWhi5pOumnSB0k8Lkb24ibUyawsYhD-P2H6gDUMOgflpQonYMKx9Ov6JmqbtY2uylIo2Moo4-9XbzfV'
    };

    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    final postUrl = 'https://fcm.googleapis.com/fcm/send';
    try {
      final response = await Dio(options).post(postUrl, data: data);

      if (response.statusCode == 200) {
        // debugPrint('message sent');
      } else {
        // debugPrint('notification sending failed');
        // on failure do sth
      }
    } catch (e) {
      // debugPrint('exception $e');
    }
  }

  bool isInternet = true;

  checkInternet() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      setState(() {
        isInternet = true;
      });
      // setState(() {
      //   isLoading = false;
      // });
      // debugPrint('internet hai ');
    } else {
      setState(() {
        isInternet = false;
      });
      // debugPrint('internet nhi hai');
    }
  }

  Future<bool> _onWillPop() async {
    if (isLoaded && isInternet) {
      if (friendsList.contains(widget.userId)) {
        FirebaseFirestore.instance
            .collection('users/$userid/friends')
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
    final senderCollectionRef =
        await FirebaseFirestore.instance.collection('users').doc(userid).get();
    friendsList = senderCollectionRef['friendsList'];
    final senderMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + user.uid + '/friends')
        .doc(widget.userId)
        .get();
    final receiverBlocked = senderMessageRefs['isBlocked'];
    final receiverAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    username = receiverAccountRefs[
        'username']; // username of other person sending message
    profileLink = receiverAccountRefs['avtar'];
    receiversUserId = receiverAccountRefs['userId'];
    // if user is not blocked
    final receiverMessageRefs = await FirebaseFirestore.instance
        .collection('users/' + widget.userId + '/friends')
        .doc(user.uid)
        .get();
    final block = receiverMessageRefs['isBlocked'];
    rUsername = receiverMessageRefs['username']; // username of app holder
    setCurrentChatScreen(username);
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

  AppBar buildNocontentBar() {
    return AppBar(
      backgroundColor: Colors.grey[900],
      title: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 14),
              child: CircleAvatar(
                backgroundColor: Colors.grey[800],
                radius: 20,
              )),
          Text(
            '                       ',
            style: TextStyle(
              backgroundColor: Colors.grey[800],
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontSize: 20.0,
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
              timestamp: d,
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
                        'Sending',
                        style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey[400],
                            fontFamily: 'Montserrat'),
                      )
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
                            left: 8.0, right: 8.0, bottom: 25, top: 10),
                        child: TextField(
                          controller: messageTextController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 50,
                          // onChanged: (value) {
                          //   String trimLeft = value.trimLeft();
                          //   String trimRight = trimLeft.trimRight();
                          //   message = trimRight;
                          // },
                          cursorColor: Colors.grey[100],
                          autofocus: false,
                          style: TextStyle(
                              height: 1,
                              fontSize: 14.0,
                              color: Colors.grey[100],
                              fontFamily: 'Montserrat'),
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
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
//Sender Collections
                                    sendNotification(widget.userId, message,
                                        rUsername, user.uid);
                                    messageTextController.clear();
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

                                    sendersMessageRefs
                                        .collection('users/' +
                                            widget.userId +
                                            '/friends')
                                        .doc(user.uid)
                                        .update({
                                      'messageAt': DateTime.now(),
                                      'lastMessage': message,
                                    });

//Receiver Collections
                                    FirebaseFirestore.instance
                                        .collection('users/' +
                                            widget.userId +
                                            '/friends')
                                        .doc(user.uid)
                                        .update({
                                      'isSeen': false,
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

                                    sendersMessageRefs
                                        .collection(
                                            'users/' + user.uid + '/friends')
                                        .doc(widget.userId)
                                        .update({
                                      'messageAt': DateTime.now(),
                                      'lastMessage': message,
                                    });
                                    //userCollection of message id
                                    sendersMessageRefs
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
                                    sendersMessageRefs
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
                                    message = '';
                                    setState(() {
                                      isSending = false;
                                    });
                                  }
                                  //ashfkjdshksngldmgldfmgladnklgnkasldnglkan
                                  else {
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
                                    BorderRadius.all(Radius.circular(12)),
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
    if (choice == DropDownMenu.clearChat) {
//print('clear chat');
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                                    ? AssetImage(
                                        'assets/images/profile-user.png')
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
                )),
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
