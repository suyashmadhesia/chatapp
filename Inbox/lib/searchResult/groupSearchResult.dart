import 'package:Inbox/screens/group_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class GroupResult extends StatelessWidget {

  final groups;
  GroupResult({this.groups});

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
							showGroupProfile(groups.groupId,context, groupName: groups.groupName,groupBanner: groups.groupBanner, groupDesciption: groups.groupDescription,groupAdmins: groups.adminsId,groupMembers: groups.groupMember);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 32,
                backgroundImage:
                    groups.groupBanner == null || groups.groupBanner == ''
                        ? AssetImage('assets/images/group.png')
                        : CachedNetworkImageProvider(groups.groupBanner),
              ),
              title: Text(groups.groupName,
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

showGroupProfile(String groupId, context, {String groupName, String groupBanner, String groupDesciption, List groupAdmins, List groupMembers}){
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GroupProfileScreen(
        groupId: groupId,
        groupDescription: groupDesciption,
        groupName: groupName,
        groupBanner: groupBanner,
        groupAdmin: groupAdmins,
				groupMembers: groupMembers,
      ),
    ),
  );
}
