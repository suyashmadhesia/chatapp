import 'package:Inbox/models/group.dart';
import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:Inbox/screens/group_profile.dart';
import 'package:Inbox/searchResult/groupSearchResult.dart';
import 'package:Inbox/searchResult/userSearchResult.dart';
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

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin{
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
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(handleTabIndex);
    //getUserData();
  }

  void handleTabIndex() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

//const
  TextEditingController textEditingController = TextEditingController();
  final database = FirebaseFirestore.instance;
  TabController _tabController;
  Future<QuerySnapshot> searchResult;
  final usersRef = FirebaseFirestore.instance.collection('users');
  double screenWidth;
  double screenHeight;
  bool isSearching = false;
  Future<QuerySnapshot> groupSearchResult;

//Functions

  handleSearch(String value) {
    Future<QuerySnapshot> users =
        usersRef.where('username', isGreaterThanOrEqualTo: value).get();
    setState(() {
      searchResult = users;
    });
  }

  handleGroupSearch(String value){
    Future<QuerySnapshot> groups = 
      FirebaseFirestore.instance.collection('groups')
      .where('groupName', isGreaterThanOrEqualTo: value).get();
      setState(() {
        groupSearchResult = groups;
      });
  }

  buildGroupSearchResult(){
    if(isSearching){
      return new Align(
        child: groupSearchList(),
      );
    } else {
      return new Align(alignment: Alignment.topCenter,child: new Container());
    }
  }

  groupSearchList(){
    return FutureBuilder(
      future: groupSearchResult,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        else if(snapshot.hasData){
          if(snapshot.data.documents.length > 0){
            List<GroupResult> groupSearchResult = [];
            snapshot.data.documents.forEach((doc){
            GroupAccount groupData = GroupAccount.fromDocument(doc);
            GroupResult groupResult = GroupResult(groups : groupData);
            groupSearchResult.add(groupResult);
            });
            return ListView(
              physics: BouncingScrollPhysics(), children: groupSearchResult);
          }
          else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/images/undraw_warning_cyit.svg',
                      height: screenHeight * 230, width: screenWidth * 48),
                  SizedBox(height: screenHeight * 20),
                  Text('No data found',
                      style: TextStyle(
                          color: Colors.black, fontFamily: 'Montserrat'))
                ],
              ),
            );
          }
        }else {
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
      }
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



  AppBar buildSearchField() {
    return AppBar(
      elevation: 0,
      toolbarHeight: screenHeight * 170,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Material(
        elevation: 5,
        borderRadius: BorderRadius.all(
          Radius.circular(screenWidth * 13),
        ),
        child: TextFormField(
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter(RegExp('[a-z0-9_]'),
                allow: true) //RegEx for  only correct input taken
          ],
          style: TextStyle(
              color: Colors.black, fontFamily: 'Montserrat', fontSize: 12.0),
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
              handleGroupSearch(value);
            }
          },
          cursorColor: Colors.black,
          decoration: InputDecoration(
            isDense: true, // important line
            contentPadding: EdgeInsets.fromLTRB(
                screenWidth * 2.5, screenWidth * 3, 0, screenWidth * 3),
            focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenWidth * 13)),
                borderSide: BorderSide.none),
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenWidth * 13)),
                borderSide: BorderSide.none),
            hintText: 'Search...',
            hintStyle: TextStyle(
                color: Colors.black, fontFamily: 'Montserrat', fontSize: 12.0),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Padding(
              padding: EdgeInsets.only(left: screenWidth * 8),
              child: IconButton(
                splashRadius: 8.0,
                // onPressed: () => getUserData,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      bottom : TabBar(
          controller: _tabController,
          indicatorColor: Colors.grey[200],
          tabs: [
            Tab(
              child: Text('People',
                  style: TextStyle(
                      fontFamily: 'Mulish', fontSize: 15, color: Colors.black)),
            ),
            Tab(
              child: Text('Groups',
                  style: TextStyle(
                      fontFamily: 'Mulish', fontSize: 15, color: Colors.black)),
            )
          ],
        ),
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
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'Mulish'))),
          ],
        ),
      ),
    );
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
      body: TabBarView(
        controller: _tabController,
        physics: BouncingScrollPhysics(),
        children: [
          searchResult == null || !isSearching
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: buildNoContent())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: buildSearchResult()),
          groupSearchResult == null || !isSearching
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: buildNoContent())
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: buildGroupSearchResult()),
        ],
      ),
    );
  }
}



