import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/models/user.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:data_connection_checker/data_connection_checker.dart';
// import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'search_screen.dart';

// TODO referact code remove excess reads from firebase which checkinng functions are taking;

class OthersProfile extends StatefulWidget {
  @override
  _OthersProfileState createState() => _OthersProfileState();
  final String profileId;
  final String profileUrl;
  final String profileDescription;

  OthersProfile({this.profileId, this.profileDescription, this.profileUrl});
}

class _OthersProfileState extends State<OthersProfile>
    with TickerProviderStateMixin {
  // final _auth = FirebaseAuth.instance;
  String user = FirebaseAuth.instance.currentUser.uid;
  final userRefs = FirebaseFirestore.instance.collection('users');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    tokens = notificationData.getToken(widget.profileId);
    getUsersFriendData();
    isRequestSent();
    checkingAccept();
    friendCheck();
  }

//CollectionField Constant
  List userRequestList;
  var tokens;
  List userPendingList;
  List userFriendsList;

  List receiverPendingList;
  List receiverRequestList;
  List receiverFriendsList;

  bool isSentRequest = false;
  bool showAccepted = false;
  bool isFriends = false;
  String username;
  String avatar;
  String rUsername;
  bool isSeen = false;
  bool isInternet = true;
  bool isLoading = false;
  double screenHeight;
  double screenWidth;
  bool dataLoaded = false;

  final SendNotification notificationData = SendNotification();


  checkingAccept() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    final receiverAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.profileId)
        .get();
    if (userAccountRefs['pendingList'].contains(widget.profileId) &&
        receiverAccountRefs['requestList'].contains(user)) {
      setState(() {
        showAccepted = true;
      });
    }
  }
// TODO wrap all function in one functions in checkStatus function;
  // checkStatus() async {
  //   final userAccountRefs =
  //       await FirebaseFirestore.instance.collection('users').doc(user).get();
  //   final receiverAccountRefs = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.profileId)
  //       .get();
  //   if (userAccountRefs['pendingList'].contains(widget.profileId) &&
  //       receiverAccountRefs['requestList'].contains(user)) {
  //     setState(() {
  //       showAccepted = true;
  //     });
  //   }
  // }

  getUsersFriendData() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    userRequestList = userAccountRefs['requestList'];
    userPendingList = userAccountRefs['pendingList'];
    userFriendsList = userAccountRefs['friendsList'];
    username = userAccountRefs['username'];
    avatar = userAccountRefs['avtar'];
    final receiverAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.profileId)
        .get();
    receiverPendingList = receiverAccountRefs['pendingList'];
    receiverRequestList = receiverAccountRefs['requestList'];
    receiverFriendsList = receiverAccountRefs['friendsList'];
    rUsername = receiverAccountRefs['username'];
    setState(() {
      dataLoaded = true;
    });
  }

  isRequestSent() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    final receiverAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.profileId)
        .get();
    if (userAccountRefs['requestList'].contains(widget.profileId) &&
        receiverAccountRefs['pendingList'].contains(user)) {
      setState(() {
        isSentRequest = true;
      });
    }
  }

  friendCheck() async {
    final userAccountRefs =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    final receiverAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.profileId)
        .get();
    if (userAccountRefs['friendsList'].contains(widget.profileId) &&
        receiverAccountRefs['friendsList'].contains(user)) {
      setState(() {
        isFriends = true;
      });
    }
  }

//All functions of sending,cancel , accepting, denying and deleting a friendRequest

  sendFriendRequest() async {
    if (!userFriendsList.contains(widget.profileId) &&
        !receiverFriendsList.contains(user)) {
      if (!userRequestList.contains(widget.profileId) &&
          !receiverPendingList.contains(user) &&
          !userPendingList.contains(widget.profileId) &&
          !receiverRequestList.contains(user)) {
        await userRefs.doc(user).update({
          'requestList': FieldValue.arrayUnion([widget.profileId]),
        });
        //print('working');
        await userRefs.doc(widget.profileId).update({
          'pendingList': FieldValue.arrayUnion([user]),
        });
        final receiverCollectionRef = FirebaseFirestore.instance
            .collection('users/' + widget.profileId + '/pendingRequests');
        receiverCollectionRef.doc(user).set({
          'pendingUserId': user,
          'SendersUsername': username,
          'SendersAvatar': avatar,
          'requestType': 'FriendRequest',
          'sendAt': DateTime.now(),
          'targetName' : rUsername,
          'targetId' : widget.profileId,
        });
      }
    }
    //Sending notification here;
    notificationData.sendOtherNotification(
        'New Friend Request',
        user,
        widget.profileId,
        '$username sent you friend request !!',
        'Friend Request',
        tokens: tokens,
        isMuted: false);

    setState(() {
      isSentRequest = true;
    });
  }

  cancelFriendRequest() async {
    List<String> userIdOfSender = [];
    userIdOfSender.add('$user');
    List<String> userIdOfReceiver = [];
    userIdOfReceiver.add(widget.profileId);
    if (!userFriendsList.contains(widget.profileId) &&
        !receiverFriendsList.contains(user)) {
      if (userRequestList.contains(widget.profileId) &&
          receiverPendingList.contains(user)) {
        await userRefs.doc(user).update({
          'requestList': FieldValue.arrayRemove(userIdOfReceiver),
        });
        //print('I am Working');
        //print(userIdOfSender);
        await userRefs.doc(widget.profileId).update({
          'pendingList': FieldValue.arrayRemove(userIdOfSender),
        });
        final receiverCollectionRef = FirebaseFirestore.instance
            .collection('users/' + widget.profileId + '/pendingRequests');
        receiverCollectionRef.doc(user).delete();
      }
    }
    setState(() {
      isSentRequest = false;
    });
  }

  acceptFriendRequest() async {
    List<String> userIdOfSender = [];
    userIdOfSender.add('$user');
    List<String> userIdOfReceiver = [];
    userIdOfReceiver.add(widget.profileId);
    if (!userFriendsList.contains(widget.profileId) &&
        !receiverFriendsList.contains(user)) {
      if (userPendingList.contains(widget.profileId) &&
          receiverRequestList.contains(user)) {
        final messageCollection =
            await FirebaseFirestore.instance.collection('messages').add({
          'userId1': user,
          'userId2': widget.profileId,
        });
        final messageCollectionId = messageCollection.id;
        userRefs.doc(user).update({
          'pendingList': FieldValue.arrayRemove(userIdOfReceiver),
        });
        //print(userIdOfSender);
        userRefs.doc(user).update({
          'friendsList': FieldValue.arrayUnion([widget.profileId]),
        });

        userRefs.doc(widget.profileId).update({
          'requestList': FieldValue.arrayRemove(userIdOfSender),
        });
        userRefs.doc(widget.profileId).update({
          'friendsList': FieldValue.arrayUnion([user]),
        });
        final senderCollectionRef =
            FirebaseFirestore.instance.collection('users/$user/friends');
        senderCollectionRef.doc(widget.profileId).set({
          'isFriend': true,
          'isBlocked': false,
          'userId': widget.profileId,
          'username': rUsername,
          'friendsAt': DateTime.now(),
          'messageAt': DateTime.now(),
          'isSeen': isSeen,
          'lastMessage': 'Say hi to $rUsername',
          'messageCollectionId': messageCollectionId,
          'isMuted': false,
        });
        final receiverCollectionRef = FirebaseFirestore.instance
            .collection('users/' + widget.profileId + '/friends');
        receiverCollectionRef.doc(user).set({
          'isFriend': true,
          'isBlocked': false,
          'userId': user,
          'username': username,
          'friendsAt': DateTime.now(),
          'messageAt': DateTime.now(),
          'isSeen': isSeen,
          'lastMessage': 'Say hi to $username',
          'messageCollectionId': messageCollectionId,
          'isMuted': false,
        });
        final receiverCollectionRefs = FirebaseFirestore.instance
            .collection('users/$user/pendingRequests');
        receiverCollectionRefs.doc(widget.profileId).delete();
      }
    }
    notificationData.sendOtherNotification(
        'Friend Request Accepted',
        user,
        widget.profileId,
        '$username Accepted your Friend Request !!',
        'Request Accepted',
        tokens: tokens,
        isMuted: false);
    setState(() {
      showAccepted = false;
    });
  }

  unfriending() async {
    if (userFriendsList.contains(widget.profileId) &&
        receiverFriendsList.contains(user)) {
      final senderMessageCollectionRef = FirebaseFirestore.instance
          .collection('users/$user/friends/' + widget.profileId + '/messages');
      await senderMessageCollectionRef.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
      final receiverMessageCollectionRef = FirebaseFirestore.instance
          .collection('users/' + widget.profileId + '/friends/$user/messages');
      await receiverMessageCollectionRef.get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      final senderCollectionRef =
          FirebaseFirestore.instance.collection('users/$user/friends');
      await senderCollectionRef.doc(widget.profileId).delete();
      final receiverCollectionRef = FirebaseFirestore.instance
          .collection('users/' + widget.profileId + '/friends');
      await receiverCollectionRef.doc(user).delete();
      userRefs.doc(user).update({
        'friendsList': FieldValue.arrayRemove([widget.profileId]),
      });
      userRefs.doc(widget.profileId).update({
        'friendsList': FieldValue.arrayRemove([user]),
      });
    }
  }

  denyingFriendRequest() {
    List<String> userIdOfSender = [];
    userIdOfSender.add('$user');
    List<String> userIdOfReceiver = [];
    userIdOfReceiver.add(widget.profileId);
    if (!userFriendsList.contains(widget.profileId) &&
        !receiverFriendsList.contains(user)) {
      if (userPendingList.contains(widget.profileId) &&
          receiverRequestList.contains(user)) {
        userRefs.doc(user).update({
          'pendingList': FieldValue.arrayRemove(userIdOfReceiver),
        });

        userRefs.doc(widget.profileId).update({
          'requestList': FieldValue.arrayRemove(userIdOfSender),
        });
        final receiverCollectionRef = FirebaseFirestore.instance
            .collection('users/$user/pendingRequests');
        receiverCollectionRef.doc(widget.profileId).delete();
      }
    }
    setState(() {
      showAccepted = false;
    });
  }

  buildProfileButton() {
    if (showAccepted && !isFriends && !isSentRequest) {
      return Column(
        children: [
          Text(
            'This user had sent you friend request..',
            style: TextStyle(
                color: Colors.grey, fontFamily: 'Mulish', fontSize: 18.0),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                color: Colors.blue[900],
                splashColor: Colors.blue[200],
                onPressed: () async {
                  await acceptFriendRequest();
                  SnackBar snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    content: Text('Request Accepted !',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  );
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.pop(context);
                  //Navigator.pushNamed(context,'chat_screen');
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.blue[900], width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Text(
                    "Accept",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Montserrat'),
                  ),
                ),
              ),
              FlatButton(
                color: Colors.white,
                splashColor: Colors.blue[200],
                onPressed: () async {
                  await denyingFriendRequest();
                  SnackBar snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    content: Text('Request Denied !',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                  );
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  await Future.delayed(Duration(seconds: 1));
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.blue[900], width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (!showAccepted && isFriends && !isSentRequest) {
      return FlatButton(
        color: Colors.white,
        splashColor: Colors.blue[200],
        onPressed: () async {
          if (!isLoading) {
            setState(() {
              isLoading = true;
            });
            await unfriending();
            setState(() {
              isLoading = false;
            });
          }
          SnackBar snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            content: Text('Unfriend Done !',
                style: TextStyle(
                  color: Colors.white,
                )),
          );
          _scaffoldKey.currentState.showSnackBar(snackBar);
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.blue[900], width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: !isLoading
              ? Text(
                  "Unfriend",
                  style: TextStyle(
                      color: Colors.blue[900], fontFamily: 'Montserrat'),
                )
              : SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  )),
        ),
      );
    } else {
      return FlatButton(
        color: Colors.blue[900],
        splashColor: Colors.blue[600],
        onPressed: () async {
          if (isSentRequest) {
            if (!isLoading)
              setState(() {
                isLoading = true;
              });
            await cancelFriendRequest();
            await getUsersFriendData();
            await isRequestSent();
            setState(() {
              isLoading = false;
              isSentRequest = false;
            });
            SnackBar snackBar = SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
              content: Text('Request Cancelled !',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          } else if (!isSentRequest) {
            if (!isLoading)
              setState(() {
                isLoading = true;
              });
            await sendFriendRequest();
            await getUsersFriendData();
            await isRequestSent();
            setState(() {
              isLoading = false;
              isSentRequest = true;
            });
            SnackBar snackBar = SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
              backgroundColor: Colors.red,
              content: Text('Request Sent !',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            );
            _scaffoldKey.currentState.showSnackBar(snackBar);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.blue[900], width: 2),
        ),
        child: Padding(
          padding: !isLoading
              ? const EdgeInsets.fromLTRB(16, 16, 16, 16)
              : const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: !isLoading
              ? Text(
                  isSentRequest ? 'Cancel Request' : 'Add Friend',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                )
              : SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
        ),
      );
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRefs.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Account user = Account.fromDocument(snapshot.data);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: screenHeight * 70,
              backgroundColor: Colors.grey[100],
              backgroundImage: user.avtar == ''
                  ? AssetImage('assets/images/user.png')
                  : CachedNetworkImageProvider(user.avtar),
            ),
            Padding(
              padding: EdgeInsets.all(screenHeight * 21.34),
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            SizedBox(height: screenHeight * 26),
            buildProfileButton(),
            SizedBox(height: screenHeight * 50),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Text(
                  user.bio == ''
                      ? user.username + ' has not provided bio yet'
                      : user.bio,
                  style: TextStyle(
                      color: Colors.grey, fontFamily: 'Mulish', fontSize: 18.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text('Profile',
            style: TextStyle(fontFamily: 'Montserrat', color: Colors.black)),
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: dataLoaded
            ? buildProfileHeader()
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
