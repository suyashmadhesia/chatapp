import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:Inbox/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  User currentUser = FirebaseAuth.instance.currentUser;

  void setCurrentScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("path", "");
    prefs.setString("current_user_on_screen", "");
  }

  @override
  void initState() {
    super.initState();
    setCurrentScreen();
    //getUserData();
  }

//const
  TextEditingController textEditingController = TextEditingController();
  final database = FirebaseFirestore.instance;
  Future<QuerySnapshot> searchResult;
  final usersRef = FirebaseFirestore.instance.collection('users');
  double screenWidth;
  double screenHeight;

//Functions

  handleSearch(String value) {
    Future<QuerySnapshot> users =
        usersRef.where('username', isGreaterThanOrEqualTo: value).get();
    setState(() {
      searchResult = users;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      toolbarHeight: screenHeight * 100,
      backgroundColor: Colors.grey[900],
      automaticallyImplyLeading: false,
      title: TextFormField(
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter(RegExp('[a-z0-9_]'),
                allow: true) //RegEx for  only correct input taken
          ],
          style: TextStyle(
              color: Colors.grey[700],
              fontFamily: 'Montserrat',
              fontSize: 14.0),
          onChanged: handleSearch,
          cursorColor: Colors.grey[600],
          decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: 'Search here .....',
              hintStyle: TextStyle(
                  color: Colors.grey, fontFamily: 'Montserrat', fontSize: 14.0),
              filled: true,
              fillColor: Colors.grey[300],
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
                    color: Colors.grey[600],
                  ),
                ),
              ))),
    );
  }

  Container buildNoContent() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text('Search new user here......',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontFamily: 'Mulish'))),
          ],
        ),
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
      future: searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0) {
            List<UserResult> searchResult = [];
            snapshot.data.documents.forEach((doc) {
              Account users = Account.fromDocument(doc);
              if (users.userId != currentUser.uid) {
                UserResult userResult = UserResult(user: users);
                searchResult.add(userResult);
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

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body: searchResult == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatefulWidget {
  final user;
  UserResult({this.user});
  @override
  _UserResultState createState() => _UserResultState();
}

class _UserResultState extends State<UserResult> {
  String thisUserID;
  String userid = _SearchScreenState().currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              //await getUserData();
              if (widget.user.userId == userid) {
                currentUserProfile(context, profileId: userid);
              } else if (widget.user.userId != userid) {
                thisUserID = widget.user.userId;
                showProfile(context, profileId: widget.user.userId);
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 32,
                backgroundImage:
                    widget.user.avtar == null || widget.user.avtar == ''
                        ? AssetImage('assets/images/user.png')
                        : CachedNetworkImageProvider(widget.user.avtar),
              ),
              title: Text(widget.user.username,
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 18,
                      fontFamily: 'Monstserrat')),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            color: Colors.grey[500],
            height: 2.0,
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

currentUserProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(
        profileId: profileId,
      ),
    ),
  );
}
