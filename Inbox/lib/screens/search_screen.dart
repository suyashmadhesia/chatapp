// import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Inbox/screens/friends_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

//const
  TextEditingController textEditingController = TextEditingController();
  final database = FirebaseFirestore.instance;
  Future<QuerySnapshot> searchResult;
  final usersRef = FirebaseFirestore.instance.collection('users');

//Functions

  handleSearch(String value){
    Future<QuerySnapshot> users = usersRef.where('username', isEqualTo: value).get();
    setState(() {
      searchResult = users;
    });

  }


  AppBar buildSearchField(){
    return AppBar(
      toolbarHeight: 75,
      backgroundColor: Colors.grey[900],
      automaticallyImplyLeading: false,
      title: TextFormField(
        onChanged: handleSearch,
        cursorColor: Colors.grey[600],
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          hintText: 'Search here......',
          hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Montserrat', fontSize: 14.0),
          filled: true,
          fillColor: Colors.grey[300],
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: IconButton(
              splashRadius: 8.0,
              onPressed: (){
                FocusScope.of(context).unfocus();
              },
              icon: Icon(Icons.search,
              color: Colors.grey[600],
              ),
            ),
          )
        )
      ),
    );
  }

  Container buildNoContent(){
    return Container(
      color: Colors.white,
      child: Center(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            SizedBox(height: 175,),
            SvgPicture.asset('assets/images/search.svg', height: 200, width: 200),
            Center(child: Text('Search for new friends...',style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Mulish'))),
          ],
        ),
        ),
      );
    }

    buildSearchResult(){
      return FutureBuilder(
        future: searchResult,
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          else{
            List<UserResult> searchResult = [];
            snapshot.data.documents.forEach((doc){
              
              Account users = Account.fromDocument(doc);
              UserResult userResult = UserResult(users);
              searchResult.add(userResult);
            });
            return ListView(physics: BouncingScrollPhysics(),
              children: searchResult
                
             
            );
          }
        },
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body: searchResult == null ?  buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {

  final Account user;

  UserResult( this.user );
  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(children: [
        GestureDetector(
          onTap: () => print('tapped'),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.avtar == null || user.avtar == '' ? AssetImage('assets/images/profile-user.png') : CachedNetworkImageProvider(user.avtar),
            ),
            title: Text(user.username, style: TextStyle(color: Colors.grey[900], fontSize: 18, fontFamily: 'Monstserrat')),
          ),
        ),
        Divider(color: Colors.grey[500],height: 2.0,)
      ],),
    );
  }
}