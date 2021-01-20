import 'dart:async';
import 'dart:io';

import 'package:Inbox/assets_manager/image_picker.dart';
import 'package:Inbox/components/message_bubble.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:Inbox/helpers/firestore.dart';
import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/models/message.dart';
// import 'package:dio/dio.dart';
import 'package:Inbox/models/constant.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:Inbox/state/global.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
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
  GlobalState globalState = GlobalState();

  String stateName() {
    return "${widget.userId}_messages";
  }

  @override
  void initState() {
    super.initState();
    // globalState[stateName()] = [];
    getUserData();
    checkInternet();

    setIsSeen();
  }

  StreamController<dynamic> chatStreamController;

  Stream<dynamic> getChatStream(Iterable<dynamic> datas) {
    void start() {
      for (var data in datas) {
        chatStreamController.add(data);
      }
    }

    void stop() {
      chatStreamController.close();
    }

    if (chatStreamController == null) {
      chatStreamController = StreamController<dynamic>(
        onListen: start,
        onPause: stop,
        onResume: start,
        onCancel: start,
      );
    }
    return chatStreamController.stream;
  }

  final messageTextController = TextEditingController();
  final SendNotification notificationData = SendNotification();
  final user = FirebaseAuth.instance.currentUser;
  final sendersMessageRefs = FirebaseFirestore.instance;
  final receiverMessageRefs = FirebaseFirestore.instance;
  final messageCollectionRefs = FirebaseFirestore.instance;
  final DateTime timeStamp = DateTime.now();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String rUsername;
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
  ScreenSize scale;
  List<Asset> assets = [];
  bool isShowingBS = false;

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

  checkInternet() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      setState(() {
        isInternet = true;
      });
    } else {
      setState(() {
        isInternet = false;
      });
    }
  }

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
    rUsername = receiverMessageRefs[
        'username']; // my user name means the name of current sender
    isSeen = receiverMessageRefs['isSeen'];

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

  Widget showModalBottomSheet(BuildContext context) {
    return Container(
        width: scale.horizontal(100),
        height: scale.vertical(40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(52), topRight: Radius.circular(12)),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: scale.horizontal(2), vertical: scale.vertical(1.2)),
        margin: EdgeInsets.only(bottom: scale.vertical(10)),
        child: Column(
          children: [
            ListTile(
              trailing: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isShowingBS = false;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Photo / Video'),
              leading: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: scale.vertical(2),
                      horizontal: scale.horizontal(4)),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 2)),
                  child: Icon(Icons.image)),
              onTap: () async {
                List<File> files = await FileManager.pickMediaFile();
                if (files.length > 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageVideoPickerScreen(
                                user: user,
                                avatar: avatar,
                                files: files,
                              )));
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(top: scale.vertical(2)),
              child: ListTile(
                title: Text('Audio'),
                leading: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: scale.vertical(2),
                        horizontal: scale.horizontal(4)),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green[600], width: 2)),
                    child: Icon(Icons.audiotrack)),
                onTap: () {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: scale.vertical(2)),
              child: ListTile(
                title: Text('Documents'),
                leading: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: scale.vertical(2),
                        horizontal: scale.horizontal(4)),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepOrange, width: 2)),
                    child: Icon(Icons.file_copy)),
                onTap: () {},
              ),
            )
          ],
        ));
  }

  MessageBubble getBubble(dynamic message, {List<Asset> assets = const []}) {
    return MessageBubble(
        timestamp: message['timestamp'].toDate(),
        senderId: user.uid,
        receiverId: widget.userId,
        myMessageId: message['messageId'],
        message: message['message'],
        sender: message['sender'] == user.uid,
        visibility: message['visibility'],
        uniqueMessageId: uniqueMessageId,
        assets: assets);
  }

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
          List messages = snapshot.data.documents;

          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            List<Asset> assets = [];
            if (message.data().containsKey("assets")) {
              if (message["assets"].length > 0 &&
                  message["assets"].length <= 4) {
                for (var asset in message["assets"]) {
                  messageBubbles
                      .add(getBubble(message, assets: [Asset.fromJson(asset)]));
                }
              } else {
                assets = (message["assets"] as List)
                    .map((e) => Asset.fromJson(e))
                    .toList();
                messageBubbles.add(getBubble(message, assets: assets));
              }
            }
          }
          if (globalState[stateName()] != null &&
              globalState[stateName()].length > 0) {
            print(globalState[stateName()]);
            messageBubbles.addAll(globalState[stateName()]);
          }

          messageBubbles.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          messageBubbles = messageBubbles.reversed.toList();
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

  sendMessage(String message, {List<Asset> providedAssets = const []}) async {
    final messageDoc = await messageCollectionRefs
        .collection('messages/$uniqueMessageId/conversation')
        .add({
      'sender': user.uid,
      'message': message,
      'timestamp': DateTime.now(),
      'messageId': '',
      'assets': assets.map((e) => e.toJson()),
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

  Future<List<Asset>> uploadAssets(List<File> files) async {
    List<Asset> assets = [];
    for (File file in files) {
      assets.add(Asset(file: file));
      int index = assets.length - 1;
      print('$index ${assets.length}');
      assets[index].contentType = FileManager.getMimeType(file);
      assets[index].setNameGenerated();
      if (FileManager.isImage(file)) {
        assets[index].thumbnailFile = await FileManager.compressImage(file);
        var ref = FireStore.getAssetRef(
            'media/${assets[index].name}-thumb.${assets[index].getContent()}');
        var task =
            FireStore.getUploadTaskUni8List(ref, assets[index].thumbnailFile);
        task.whenComplete(() async =>
            {assets[index].thumbnail = await FireStore.getDownloadUrl(task)});
      }
      var fileRef = FireStore.getAssetRef(
          'media/${assets[index].name}.${assets[index].getContent()}');
      var fileTask = FireStore.getUploadTask(fileRef, file);
      assets[index].task = fileTask;
      assets[index].task.whenComplete(() async =>
          {assets[index].url = await FireStore.getDownloadUrl(fileTask)});
    }
    return assets;
  }

  void onAddAssetClick(BuildContext context) async {
    showModalBottomSheet(context);
  }

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
                                setState(() {
                                  isShowingBS = true;
                                  FocusScope.of(context).unfocus();
                                });
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
                                    // sendNotification(widget.userId, message,
                                    //     rUsername, user.uid);
                                    messageTextController.clear();
                                    //TODO here messege is save in senders db
                                    await sendMessage(message);

                                    setState(() {
                                      isSending = false;
                                    });
                                    await notificationData.sendNotification(
                                      'New message from $rUsername',
                                      user.uid,
                                      widget.userId,
                                      message,
                                      'Private Message',
                                      isMuted: isMute,
                                    );
                                    message = '';
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

  unMuteChat() {
    setState(() {
      isMute = false;
    });
    debugPrint('un muted');
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
    setState(() {
      isMute = true;
    });
    debugPrint('Muted');
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
    scale = ScreenSize(context: context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xff111111),
        bottomSheet: (isShowingBS) ? showModalBottomSheet(context) : null,
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
