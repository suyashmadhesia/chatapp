// import 'package:firebase_core/firebase_core.dart';
import 'package:Inbox/reusable/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  final String _collection = 'users';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // void getUsers() async {
  //   await for (var snapshot in _fireStore.collection(_collection).snapshots()) {
  //     for (var user in snapshot.docs) {
  //       print(user.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        title: const Text('Serach', textAlign: TextAlign.center),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[                       
            StreamBuilder<QuerySnapshot>(
                stream: _fireStore.collection(_collection).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                  final users = snapshot.data.docs;
                  List<UserBubble> userWidgets = [];
                  for (var user in users) {
                    final userName = user.data()['username'];
                    final userWidget = UserBubble(username: userName);                  
                    userWidgets.add(userWidget);
                  }
                  return Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      children: userWidgets,
                    ),
                  );
                }),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

class UserBubble extends StatelessWidget {
  UserBubble({this.username});

  final String username;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Column(
                  children: [
                    Text(
                      '$username',
                      style: TextStyle(fontSize: 20.0, color: Colors.black),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'online',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            // SizedBox(height:20.0),
            Padding(
              padding: EdgeInsets.only(left: 0.0, top: 20.0, right: 0.0),
              child: Container(
                height: 1.0,
                color: Colors.black12,
              ),
            )
          ],
        ),
      ),
    );
  }
}
