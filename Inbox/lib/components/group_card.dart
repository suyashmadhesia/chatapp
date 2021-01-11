import 'package:Inbox/components/screen_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class GroupCard extends StatefulWidget {
  final String groupName;
  final String groupBanner;
  final String groupId;
  final DateTime messageAt;
  final String lastMessage;

  GroupCard(
      {this.groupName,
      this.messageAt,
      this.lastMessage,
      this.groupBanner,
      this.groupId});

  @override
  _GroupCardState createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  checkMessageSeen() {}

  double screenHeight;
  double screenWidth;
  bool isDataLoaded = false;

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          SizedBox(
            height: screenWidth * 1.1,
          ),
          GestureDetector(
            onTap: () {},
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: screenHeight * 42,
                backgroundImage:
                    widget.groupBanner == null || widget.groupBanner == ''
                        ? AssetImage('assets/images/user.png')
                        : CachedNetworkImageProvider(widget.groupBanner),
              ),
              title: Text(
                widget.groupName,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Monstserrat',
                ),
              ),
              subtitle: Text(
                widget.lastMessage,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Divider(
            color: Colors.grey[500],
            height: 2.0,
          )
        ],
      ),
    );
  }
}
