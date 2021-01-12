import 'package:Inbox/models/user.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/screens/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'search_screen.dart';

class OthersProfile extends StatefulWidget {
  @override
  _OthersProfileState createState() => _OthersProfileState();
  final String profileId;
  OthersProfile({this.profileId});
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
    checkInternet();
    getUsersFriendData();
    isRequestSent();
    checkingAccept();
    friendCheck();
  }

//CollectionField Constant
  List userRequestList;
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
      receiver, username, head, receiversUserId) async {
    var token = await getToken(receiver);
    // debugPrint('token : $token');

    final data = {
      "notification": {
        "body": username,
        "title": head,
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "type": "Profile",
        "userId": receiversUserId,
      },
      'registration_ids': token,
      "collapse_key": "$receiversUserId profile",
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
        });
        // sendNotification(widget.profileId, '$username has sent you request !!',
        //     'Friend Request', user);
      }
    }
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
        });
        final receiverCollectionRefs = FirebaseFirestore.instance
            .collection('users/$user/pendingRequests');
        receiverCollectionRefs.doc(widget.profileId).delete();
      }
    }
    setState(() {
      showAccepted = false;
    });
    // sendNotification(widget.profileId, '$username has accepted your request !!',
    //     'Request Accepted', user);
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
    return isInternet
        ? Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title:
                  Text('Profile', style: TextStyle(fontFamily: 'Montserrat')),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.grey[900],
            ),
            body: SafeArea(
              child: dataLoaded
                  ? buildProfileHeader()
                  : Center(child: CircularProgressIndicator()),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No internet :(',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontFamily: 'Mulish')),
                FlatButton(
                    padding: EdgeInsets.all(8.0),
                    color: Colors.greenAccent[700],
                    onPressed: () => checkInternet(),
                    child: Text('Retry',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Mulish')))
              ],
            )),
          );
  }
}
