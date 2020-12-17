import 'package:cloud_firestore/cloud_firestore.dart';

class Account{
  final String userId;
  final String username;
  final String bio;
  final String avtar;
  final String gender;
  final String email;
  
  Account({
    this.userId,
    this.username,
    this.bio,
    this.avtar,
    this.gender,
    this.email,
  });

  factory Account.fromDocument(DocumentSnapshot doc){
    return Account(
      userId: doc['userId'],
      username: doc['username'],
      bio: doc['bio'],
      avtar: doc['avtar'],
      gender: doc['gender'],
      email: doc['email'],
    );
  }

}