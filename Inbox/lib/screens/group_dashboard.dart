import 'package:flutter/material.dart';

class GroupDashboard extends StatefulWidget {

  final String groupId;
  final String groupName;
  final String groupDescription;
  final String groupBanner;

  GroupDashboard({this.groupId, this.groupName, this.groupBanner, this.groupDescription});

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