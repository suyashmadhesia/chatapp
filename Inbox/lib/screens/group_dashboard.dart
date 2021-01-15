import 'package:flutter/material.dart';

class GroupDashboard extends StatefulWidget {

  final String groupId;
  final String groupName;

  GroupDashboard({this.groupId, this.groupName});

  @override
  _GroupDashboardState createState() => _GroupDashboardState();
}

class _GroupDashboardState extends State<GroupDashboard> {


  //Variables
  bool isDataLoaded = false;
  bool isLoading = false;
  String bannerUrl;
  List adminsList = [];
  List membersList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}