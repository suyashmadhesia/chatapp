import 'package:Inbox/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool sender;
  final String time;
  final String myMessageId;
  final bool visibility;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final String uniqueMessageId;
  final List<Asset> assets;

  MessageBubble(
      {this.message,
      this.sender,
      this.time,
      this.myMessageId,
      this.senderId,
      this.receiverId,
      this.timestamp,
      this.visibility,
      this.uniqueMessageId,
      this.assets});

  // Function to dissolve date time into Date | Time format
  // Herby using if DateTime.now().date() == d.date() then Today
  // else Date Month
  static const Map<int, String> months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sept',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec'
  };

  String getDateFormat() {
    var now = DateTime.now();
    if (now.day == timestamp.day &&
        now.month == timestamp.month &&
        now.year == timestamp.year) {
      return 'Today | $time';
    }
    return '${timestamp.day} ${months[timestamp.month]} | $time';
  }

  //Function

  unsendMessage() async {
    await FirebaseFirestore.instance
        .collection('messages/$uniqueMessageId/conversation')
        .doc(myMessageId)
        .update({
      'visibility': false,
    });
    await FirebaseFirestore.instance
        .collection('users/$senderId/friends/')
        .doc(receiverId)
        .update({
      'lastMessage': 'This message was deleted',
    });
    await FirebaseFirestore.instance
        .collection('users/$receiverId/friends/')
        .doc(senderId)
        .update({
      'lastMessage': 'This message was deleted',
    });
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return visibility || visibility == null
        ? Padding(
            padding:
                const EdgeInsets.only(right: 8, top: 12, bottom: 4, left: 8),
            child: Column(
              crossAxisAlignment:
                  sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (visibility)
                  Padding(
                    padding: sender
                        ? EdgeInsets.only(left: screenWidth * 0.2)
                        : EdgeInsets.only(right: screenWidth * 0.2),
                    child: sender
                        ? FocusedMenuHolder(
                            duration: Duration(milliseconds: 100),
                            menuItemExtent:
                                MediaQuery.of(context).size.height * 0.05,
                            blurBackgroundColor: Colors.grey[600],
                            blurSize: 0,
                            menuWidth: MediaQuery.of(context).size.width * 0.3,
                            // duration: Duration(milliseconds: 50),
                            onPressed: () {},
                            menuItems: <FocusedMenuItem>[
                              FocusedMenuItem(
                                  title: Text(
                                    'Unsend',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    await unsendMessage();
                                  },
                                  backgroundColor: Colors.redAccent,
                                  trailingIcon: Icon(
                                    Icons.delete,
                                    size: screenWidth * 0.05,
                                    color: Colors.white,
                                  ))
                            ],
                            child: Material(
                              elevation: 5,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: sender
                                  ? Colors.purple[800]
                                  : Colors.grey[800], //Color(0xff5ddef4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                child: Text(
                                  message,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Montserrat'),
                                ),
                              ),
                            ),
                          )
                        : Material(
                            elevation: 5,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: sender
                                ? Colors.purple[800]
                                : Colors.grey[800], //Color(0xff5ddef4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 12),
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat'),
                              ),
                            ),
                          ),
                  ),
                if (visibility)
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 6),
                    child: Text(
                      getDateFormat(),
                      style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 9,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
              ],
            ),
          )
        : Padding(
            padding:
                const EdgeInsets.only(right: 8, top: 12, bottom: 4, left: 8),
            child: Column(
              crossAxisAlignment:
                  sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: sender
                      ? EdgeInsets.only(left: screenWidth * 0.2)
                      : EdgeInsets.only(right: screenWidth * 0.2),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: sender
                        ? Colors.purple[800]
                        : Colors.grey[800], //Color(0xff5ddef4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      child: Text(
                        'This message was deleted',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 8, left: 6),
                    child: Text(
                      getDateFormat(),
                      style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 9,
                          fontFamily: 'Montserrat'),
                    ))
              ],
            ),
          );
  }
}

class AssetWidget extends StatelessWidget {
  final Asset asset;
  final Function onTap;
  const AssetWidget(this.asset, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
