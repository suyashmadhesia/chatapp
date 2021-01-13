import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/screens/profile_other.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String username;
  final String id;
  final String time;
  final String avatar;
  final requestType;
  final DateTime timeStamp;

  NotificationCard(
      {this.avatar,
      this.time,
      this.id,
      this.username,
      this.requestType,
      this.timeStamp});

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    double screenHeight = screenSize.dividingHeight();
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: id);
            },
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: screenHeight * 42,
                  backgroundImage: avatar == '' || avatar == null
                      ? AssetImage('assets/images/user.png')
                      : CachedNetworkImageProvider(avatar)),
              title: Text(
                  username + ' sent you friend request tap to accept or reject',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Monstserrat')),
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

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OthersProfile(
        profileId: profileId,
      ),
    ),
  );
}
