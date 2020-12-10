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
      body: Center(
        child: Text('Search',
        style: TextStyle(color: Colors.black),
        ),
        ),
      
    );
  }
}

