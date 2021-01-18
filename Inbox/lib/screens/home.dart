import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/friends_screen.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:Inbox/screens/search_screen.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';
// import 'notification_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');

// final DateTime timestamp = DateTime.now();
// User currentUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  // TODO: BUG Bigger than cock
  User user = FirebaseAuth.instance.currentUser;
//Init state
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@drawable/ic_app');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (message['data']['isMuted'] == false) {
          if (message['data']['type'] == 'Private Message') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
            return;
          } else if (message['data']['type'] == 'Group Message') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          } else if (message['data']['type'] == 'Request Accepted') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          } else if (message['data']['type'] == 'Friend Request') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          }
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['isMuted'] == false) {
          if (message['data']['type'] == 'Private Message') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
            return;
          } else if (message['data']['type'] == 'Group Message') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
          } else if (message['data']['type'] == 'Request Accepted') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          } else if (message['data']['type'] == 'Friend Request') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['isMuted'] == false) {
          if (message['data']['type'] == 'Private Message') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
            return;
          } else if (message['data']['type'] == 'Group Message') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          } else if (message['data']['type'] == 'Request Accepted') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          } else if (message['data']['type'] == 'Friend Request') {
            shownotification(
                1234,
                message['notification']['title'],
                message['notification']['body'],
                message['data']['sendersUserId']);
                return;
          }
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  Future<dynamic> onSelectNotification(String payload) async {
    //do something,
    if (payload != null) {
      showChatScreen(context, profileId: payload);
      debugPrint(payload);
    }
  }

  Future<void> shownotification(
    int notificationId,
    String notificationTitle,
    String notificationContent,
    String payload, {
    String channelId = '1234',
    String channelTitle = 'Android Channel',
    String channelDescription = 'Default Android Channel for notifications',
    Priority notificationPriority = Priority.high,
    Importance notificationImportance = Importance.max,
  }) async {
    var currentRoute = ModalRoute.of(context).settings.name;
    if (currentRoute == "home_screen") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(prefs.getString("current_user_on_screen") + '' + notificationTitle);
      if (prefs.getString("path") == "chat_screen" &&
          prefs.getString("current_user_on_screen") == notificationTitle) {
        return;
      }
    }
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription,
      playSound: true,
      importance: notificationImportance,
      priority: notificationPriority,
    );
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notificationId,
      notificationTitle,
      notificationContent,
      platformChannelSpecifics,
      payload: payload,
    );
  }



  double screenHeight;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: height, width: width);

    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();

    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          FriendsScreen(),
          SearchScreen(),
          ProfileScreen(profileId: user.uid),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: screenWidth * 25,right: screenWidth * 25,bottom: screenWidth * 3.5),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.all(
            Radius.circular(screenWidth * 13),
          ),
          child: Container(
            child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(screenWidth * 13),
          ),
          child: Container(
            height: screenHeight * 75,
            color: Colors.white,
            child: TabBar(
          indicatorColor: Colors.white,
          controller: tabController,
          labelColor: Colors.pink[400],
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontSize: 10.0),
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.question_answer,
                size: 24.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.add,
                size: 24.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person,
                size: 24.0,
              ),
            ),
          ],
          // indicator: UnderlineTabIndicator(
          //   borderSide: BorderSide(color: Colors.black54, width: 0.0),
          //   insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 40.0),
          // ),
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }
}

showChatScreen(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        userId: profileId,
      ),
    ),
  );
}
