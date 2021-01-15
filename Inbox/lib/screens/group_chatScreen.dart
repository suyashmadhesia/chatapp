import 'package:Inbox/components/group_message_bubble.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/models/user.dart';
// import 'package:Inbox/screens/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
  final SendNotification notificationData = SendNotification();
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
  bool showSearchBar = false;
  bool isSearching = false;
  final usersRef = FirebaseFirestore.instance.collection('users');
  Future<QuerySnapshot> searchResult;
  bool buttonLoading = false;
  DateTime joinAt;
  bool showInvite = true;
  bool sendRequest = true;
  List pendingList = [];
  List requestList = [];

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
            bool compare = d.isAfter(joinAt);

            for (int i = 11; i <= 15; i++) {
              time = time + dateTOstring[i];
            }
            if (compare) {
              final messageBubble = GroupMessageBubble(
                message: messageText,
                messageId: messageId,
                sender: userid == senderUserId,
                timestamp: d,
                time: time,
                visibility: visibility,
                usernameOfSender: usernameOfSender,
                groupId: widget.groupId,
              );
              messageBubbles.add(messageBubble);
            }
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

  searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter(RegExp('[a-z0-9_]'),
              allow: true) //RegEx for  only correct input taken
        ],
        style: TextStyle(
            color: Colors.white, fontFamily: 'Montserrat', fontSize: 12.0),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              isSearching = false;
            });
          } else {
            setState(() {
              isSearching = true;
            });
            handleSearch(value);
          }
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          isDense: true, // important line
          contentPadding: EdgeInsets.fromLTRB(10, 12, 0, 12),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              borderSide: BorderSide.none),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              borderSide: BorderSide.none),
          hintText: 'Search...',
          hintStyle: TextStyle(
              color: Colors.white, fontFamily: 'Montserrat', fontSize: 12.0),
          filled: true,
          fillColor: Colors.grey[800],
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: IconButton(
              splashRadius: 8.0,
              // onPressed: () => getUserData,
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
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
                    String trimLeft = messageTextController.text.trimLeft();
                    String trimRight = trimLeft.trimRight();
                    message = trimRight;
                    if (message != null && message != "") {
                      getUserData();
                      if (isAbleToSendMessage) {
                        messageTextController.clear();
                        setState(() {
                          isSending = true;
                        });
                        await sendMessage(message);
                        await notificationData.sendNotification('New Message from '+widget.groupName, userid,
                            widget.groupId, message, 'Group Message',isMuted: false);
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

  getInvitationData(String userID) async {
    final userData = await collectionRefs.collection('users').doc(userID).get();
    pendingList = userData['pendingList'];
    requestList = userData['requestList'];
  }

  sendInvitation(String userID) async {
    await collectionRefs.collection('users').doc(userID).update({
      'pendingList': FieldValue.arrayUnion([widget.groupId]),
    });
    await collectionRefs
        .collection('users/' + userID + '/pendingRequests')
        .doc(widget.groupId)
        .set({
      'pendingUserId': widget.groupId,
      'SendersUsername': widget.groupName,
      'SendersAvatar': widget.groupBanner,
      'requestType': 'GroupRequestFromGroup',
      'sendAt': DateTime.now(),
    });
  }

  cancelInvitation(String userID) async {
    await collectionRefs.collection('users').doc(userID).update({
      'pendingList': FieldValue.arrayRemove([widget.groupId]),
    });
    await collectionRefs
        .collection('users/' + userID + '/pendingRequests')
        .doc(widget.groupId)
        .delete();
  }

  inviteButton(String userID) {
    return FlatButton(
      color: showInvite ? Colors.green : Colors.red,
      onPressed: () async {
        if (!buttonLoading) {
          await getInvitationData(userID);
          if (pendingList.contains(widget.groupId) &&
              !requestList.contains(widget.groupId)) {
            setState(() {
              buttonLoading = true;
            });
            print('cancel Invitation');
            await cancelInvitation(userID);
            await getInvitationData(userID);
            if (pendingList.contains(widget.groupId)) {
              setState(() {
                showInvite = false;
              });
            } else {
              showInvite = true;
            }
            setState(() {
              buttonLoading = false;
            });
          } else {
            setState(() {
              buttonLoading = true;
            });
            print('sending Invitation');
            await sendInvitation(userID);
            await getInvitationData(userID);
            if (!pendingList.contains(widget.groupId)) {
              setState(() {
                showInvite = true;
              });
            } else {
              showInvite = false;
            }
            setState(() {
              buttonLoading = false;
            });
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(showInvite ? 'Invite' : 'Cancel Invitation',
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontFamily: 'Monstserrat')),
      ),
    );
  }

  buildSearchResult() {
    if (isSearching) {
      return new Align(
          alignment: Alignment.topCenter,
          //heightFactor: 0.0,
          child: searchList());
    } else {
      return new Align(alignment: Alignment.topCenter, child: new Container());
    }
  }

  handleSearch(String value) {
    Future<QuerySnapshot> users =
        usersRef.where('username', isGreaterThanOrEqualTo: value).get();
    setState(() {
      searchResult = users;
    });
  }

  searchList() {
    return FutureBuilder(
      future: searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0) {
            List<Widget> searchResult = [];
            snapshot.data.documents.forEach((doc) {
              Account users = Account.fromDocument(doc);

              if (users.userId != userid &&
                  !users.groupList.contains(widget.groupId) &&
                  !users.requestList.contains(widget.groupId)) {
                final widgetResult = Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.5, 0.5), //(x,y)
                            blurRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          ListTile(
                            trailing: buttonLoading
                                ? SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : inviteButton(users.userId),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[800],
                              radius: screenWidth * 7.5,
                              backgroundImage:
                                  users.avtar == null || users.avtar == ''
                                      ? AssetImage('assets/images/user.png')
                                      : CachedNetworkImageProvider(users.avtar),
                            ),
                            title: Text(users.username,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Monstserrat')),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(
                            color: Colors.grey[600],
                            height: 1.0,
                          )
                        ],
                      ),
                    ));
                searchResult.add(widgetResult);
              }
            });
            return ListView(
                physics: BouncingScrollPhysics(), children: searchResult);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/images/undraw_warning_cyit.svg',
                      height: screenHeight * 230, width: screenWidth * 48),
                  SizedBox(height: screenHeight * 20),
                  Text('No user found',
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'Montserrat'))
                ],
              ),
            );
          }
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/undraw_warning_cyit.svg',
                    height: screenHeight * 230, width: screenWidth * 48),
                SizedBox(
                  height: screenHeight * 20,
                ),
                Text('Something went wrong Please try again',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Montserrat'))
              ],
            ),
          );
        }
      },
    );
  }

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
    await collectionRefs.collection('groups').doc(widget.groupId).update({
      'lastMessage': message,
      'messageAt': DateTime.now(),
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
    joinAt = joinedAt.toDate();
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

  double screenHeight;
  double screenWidth;
  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      backgroundColor: Color(0xff111111),
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 5,
        automaticallyImplyLeading: showSearchBar ? false : true,
        actions: [
          if (admin)
            IconButton(
              onPressed: () {
                if (showSearchBar) {
                  // print('working');
                  setState(() {
                    showSearchBar = false;
                    isSearching = false;
                  });
                } else if (!showSearchBar) {
                  setState(() {
                    showSearchBar = true;
                  });
                }
              },
              icon: showSearchBar
                  ? Icon(
                      Icons.close,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
            ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.black,
        title: !showSearchBar
            ? GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        backgroundImage: widget.groupBanner == '' ||
                                widget.groupBanner == null
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
              )
            : Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: searchBar()),
      ),
      body: Stack(
        children: [
          isDataLoaded
              ? bodyToBuild()
              : Center(
                  child: CircularProgressIndicator(),
                ),
          buildSearchResult(),
        ],
      ),
    );
  }
}
