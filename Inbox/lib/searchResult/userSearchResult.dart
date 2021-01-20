import 'package:Inbox/screens/profile_other.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class UserResult extends StatelessWidget{

  final user;
  UserResult({this.user});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: user.userId);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 32,
                backgroundImage:
                    user.avtar == null || user.avtar == ''
                        ? AssetImage('assets/images/user.png')
                        : CachedNetworkImageProvider(user.avtar),
              ),
              title: Text(user.username,
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 18,
                      fontFamily: 'Monstserrat')),
            ),
          ),
          SizedBox(
            height: 5,
          ),
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