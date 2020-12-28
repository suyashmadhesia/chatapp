import 'package:Inbox/models/user.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'home.dart';
import 'search_screen.dart';

class OthersProfile extends StatefulWidget {
  @override
  _OthersProfileState createState() => _OthersProfileState();
  final String profileId;
  OthersProfile({this.profileId});
}

class _OthersProfileState extends State<OthersProfile>
    with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  String user = FirebaseAuth.instance.currentUser.uid;
  final userRefs = FirebaseFirestore.instance.collection('users');
  Animation animation;
  AnimationController controller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(microseconds: 200), vsync: this);

    animation = ColorTween(begin: Colors.grey[200], end: Colors.white)
        .animate(controller);
    controller.forward();

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
          'SendersUsername' : username,
          'SendersAvatar' : avatar,
        });
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
        userRefs.doc(user).update({
          'pendingList': FieldValue.arrayRemove(userIdOfReceiver),
        });
        print(userIdOfSender);
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
          'userId' : widget.profileId,
           'username' : rUsername,
           'friendsAt' : DateTime.now(),
           'messageAt' : DateTime.now(),
        });
        final receiverCollectionRef = FirebaseFirestore.instance
            .collection('users/' + widget.profileId + '/friends');
        receiverCollectionRef.doc(user).set({
          'isFriend': true,
          'isBlocked': false,
          'userId' : user,
           'username' : username,
           'friendsAt' : DateTime.now(),
           'messageAt' : DateTime.now(),
        });
        // final receiverCollectionsRefs = FirebaseFirestore.instance
        //     .collection('users/' + widget.profileId + '/pendingRequests');
        // receiverCollectionRef.doc(user).set({
        //   'user': username,
        // });
        final receiverCollectionRefs = FirebaseFirestore.instance
            .collection('users/$user/pendingRequests');
        receiverCollectionRefs.doc(widget.profileId).delete();
      }
    }
    setState(() {
      showAccepted = false;
    });
  }

  unfriending() async{
    if (userFriendsList.contains(widget.profileId) &&
        receiverFriendsList.contains(user)) {
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
      final senderMessageCollectionRef =
          FirebaseFirestore.instance.collection('users/$user/friends/'+widget.profileId+'/messages');
      await senderCollectionRef.doc().delete();
      final receiverMessageCollectionRef = FirebaseFirestore.instance
          .collection('users/' + widget.profileId + '/friends/$user/messages');
      await receiverCollectionRef.doc().delete();
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
                 await Future.delayed(Duration(milliseconds: 700));
                  Navigator.pop(context);
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
                  await Future.delayed(Duration(milliseconds: 700));
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
          await unfriending();
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
          await Future.delayed(Duration(milliseconds: 700));
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.blue[900], width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Text(
            "Unfriend",
            style: TextStyle(color: Colors.blue[900], fontFamily: 'Montserrat'),
          ),
        ),
      );
    } else {
      return FlatButton(
        color: Colors.blue[900],
        splashColor: Colors.blue[600],
        onPressed: () async {
          if (isSentRequest) {
            await cancelFriendRequest();
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
            await Future.delayed(Duration(milliseconds: 700));
            Navigator.pop(context);
          } else if (!isSentRequest) {
            await sendFriendRequest();
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
            await Future.delayed(Duration(milliseconds: 700));
            Navigator.pop(context);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.blue[900], width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Text(
            isSentRequest ? 'Cancel Request' : 'Add Friend',
            style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
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
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //SizedBox(height: 150.0),
              SkeletonAnimation(
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: animation.value,
                  backgroundImage:
                      AssetImage('assets/images/profile-user.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonAnimation(
                  child: Text(
                    '                       ',
                    style: TextStyle(
                      backgroundColor: animation.value,
                      color: Colors.black,
                      fontSize: 24.0,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FlatButton(
                    color: animation.value,
                    splashColor: Colors.grey[400],
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(color: Colors.grey[50], width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      child: Text(
                        "                         ",
                        style: TextStyle(
                            color: Colors.grey, fontFamily: 'Montserrat'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              SkeletonAnimation(
                child: Text(
                  '                                      ',
                  style: TextStyle(
                      backgroundColor: animation.value,
                      color: Colors.grey,
                      fontFamily: 'Mulish',
                      fontSize: 16.0),
                ),
              ),
            ],
          ));
        }
        Account user = Account.fromDocument(snapshot.data);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
           
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.grey[100],
              backgroundImage: user.avtar == ''
                  ? AssetImage('assets/images/profile-user.png')
                  : CachedNetworkImageProvider(user.avtar),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            SizedBox(height: 20.0),
            buildProfileButton(),
            SizedBox(height: 40.0),
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontFamily: 'Montserrat')),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: buildProfileHeader(),
      ),
    );
  }
}
