import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/screens/friends_screen.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:Inbox/screens/search_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';
import 'notification_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance.collection('users');

// final DateTime timestamp = DateTime.now();
// User currentUser;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int pageIndex = 0;

  final FirebaseMessaging _fcm = FirebaseMessaging();
  var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print("onMessage: $message");
        if (message['data']['type'] == 'Message') {
          shownotification(1234, message['notification']['title'],
              message['notification']['body'], message['data']['userId']);
          return;
        } else if (message['data']['type'] == 'Profile' &&
            message['notification']['title'] == 'Request Accepted') {
          shownotification(1234, message['notification']['title'],
              message['notification']['body'], message['data']['userId']);
          return;
        }
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {
        // print("onResume: $message");
        if (message['data']['type'] == 'Message') {
          shownotification(1234, message['notification']['title'],
              message['notification']['body'], message['data']['userId']);
          return;
        } else if (message['data']['type'] == 'Profile' &&
            message['notification']['title'] == 'Request Accepted') {
          shownotification(1234, message['notification']['title'],
              message['notification']['body'], message['data']['userId']);
          return;
        }
      },
    );
    getUserData();
    checkInternet();
    pageController = PageController();
  }

  bool isLoading = false;

  bool isInternet = true;

  Future<dynamic> onSelectNotification(String payload) async {
    //do something,
    showChatScreen(context, profileId: payload);
    debugPrint(payload);
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

  checkInternet() async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      setState(() {
        isInternet = true;
      });
      setState(() {
        isLoading = false;
      });
      // debugPrint('internet hai ');
    } else {
      setState(() {
        isInternet = false;
      });
      // debugPrint('internet nhi hai');
    }
  }

  // TODO: BUG Bigger than cock
  User user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(
      pageIndex,
    );
    getUserData();
    checkInternet();
  }

  List userPendingList;
  bool showNotification = false;
  getUserData() async {
    final userAccountRefs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    userPendingList = userAccountRefs['pendingList'];
    if (userPendingList.isNotEmpty) {
      setState(() {
        showNotification = true;
      });
    } else {
      setState(() {
        showNotification = false;
      });
    }
  }

  double screenHeight;
  double screenWidth;
  Scaffold buildAuthScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          FriendsScreen(),
          SearchScreen(),
          NotificationScreen(),
          if (user != null) ProfileScreen(profileId: user.uid),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: Duration(milliseconds: 400),
        color: Colors.grey[900],
        backgroundColor: Colors.white,
        height: screenHeight * 70,
        items: <Widget>[
          Icon(
            Icons.question_answer,
            size: 20,
            color: Colors.white,
          ),
          Icon(
            Icons.search,
            size: 20,
            color: Colors.white,
          ),
          Stack(
            children: [
              Icon(
                Icons.notifications,
                size: 20,
                color: Colors.white,
              ),
              showNotification
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent,
                          border:
                              Border.all(color: Colors.redAccent, width: 1)))
                  : Container(width: 4, height: 4, color: Colors.grey[900]),
            ],
          ),
          Icon(
            Icons.person,
            size: 20,
            color: Colors.white,
          ),
        ],
        // animationDuration: Duration(milliseconds: 200),

        // animationCurve: Curves.bounceInOut,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: height, width: width);

    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();

    return isInternet
        ? buildAuthScreen()
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) CircularProgressIndicator(),
                Text('No internet :(',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontFamily: 'Mulish')),
                FlatButton(
                    padding: EdgeInsets.all(8.0),
                    color: Colors.greenAccent[700],
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      checkInternet();
                    },
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
