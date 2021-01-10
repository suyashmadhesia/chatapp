import 'package:firebase_auth/firebase_auth.dart';

class GroupParticipant {
  final User user;
  final DateTime joined;
  DateTime lastActivity;
  bool isAdmin;
  GroupParticipant(
      {this.joined, this.user, this.lastActivity, this.isAdmin = false});
}

class Group {
  String name;
  final String gid;
  String image;
  final DateTime created;
  String description;
  bool isMute;
  final User creator;
  List<GroupParticipant> participants;

  Group(
      {this.name,
      this.gid,
      this.image,
      this.created,
      this.creator,
      this.description,
      this.isMute,
      this.participants});

  void addUserOnDatabase(User user) {}

  void addParticpant(User user) {
    this.participants.add(GroupParticipant(
        user: user, joined: DateTime.now(), lastActivity: DateTime.now()));
  }
}
