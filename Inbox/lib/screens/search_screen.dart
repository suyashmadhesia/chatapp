// import 'package:firebase_core/firebase_core.dart';
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
  TextEditingController textEditingController = TextEditingController();
  final database = FirebaseFirestore.instance;
  String searchString;

  @override
  Widget build(BuildContext context) {
//     children: snapshot.data.docs
//                                   .map((DocumentSnapshot document) {
// }

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0 ),
                        child: Container(  
                          height: 45.0,                      
                          decoration: BoxDecoration(color: Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),              
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, right:20.0),
                            //text TextField
                            child: TextField(
                              textInputAction: TextInputAction.go,
                              cursorColor: Colors.grey[400],
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  searchString = val.toLowerCase();
                                });
                              },
                              controller: textEditingController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                
                                  
                                  hintText: 'Search',
                                  hintStyle: TextStyle(color: Colors.grey,
                                  fontFamily: 'Montserrat'
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                      stream: (searchString == null || searchString.trim() == '')
                          ? null
                          : FirebaseFirestore.instance
                              .collection('users')
                              .where('username',
                                  isEqualTo: searchString)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('we got an error');
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return SizedBox(
                              child: Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                            );
                          case ConnectionState.none:
                            return Center(child: Text('Search users here',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Mulish',
                              fontSize: 18.0,
                            ),
                            ));

                          case ConnectionState.done:
                            return Text('we are done');

                          default:
                            return new ListView(
                                children: snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                              return Column(
                                children: [
                                  new GestureDetector(
                                    onTap: () => print('tapped'),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white,
                                        backgroundImage: document['avtar'] == '' ? AssetImage('assets/images/profile-user.png') : CachedNetworkImageProvider(document['avtar']),
                                      ),
                                     
                                      title: Text(
                                        document['username'],
                                        style: TextStyle(color: Colors.black,
                                        fontFamily: 'Mulish',
                                        fontSize: 18
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Divider(
                                      height: 1.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            }).toList());
                        }
                      },
                    )),                
                  ],
                ),
              ),
              
            ],
          ),
        ));
  }
}
