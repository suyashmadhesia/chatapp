import 'package:cloud_firestore/cloud_firestore.dart';

class GroupAccount {
  final String groupBanner;
  final String groupName;
  final String groupDescription;
  final String groupId;
  final List groupMember;
  final List adminsId;

  GroupAccount({
    this.groupName,
    this.groupDescription,
    this.groupBanner,
    this.adminsId,
    this.groupId,
    this.groupMember});

  factory GroupAccount.fromDocument(DocumentSnapshot doc){
    return GroupAccount(
      groupId: doc['groupId'],
      groupName: doc['groupName'],
      groupBanner: doc['groupBanner'],
      groupMember: doc['groupMember'],
      groupDescription: doc['groupDescription'],
      adminsId: doc['adminsId'],
    );
  }

}
