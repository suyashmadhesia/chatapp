import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class GroupMessageBubble extends StatelessWidget {
  final String message;
  final String usernameOfSender;
  final String messageId;
  final bool visibility;
  final String time;
  final DateTime timestamp;
  final List assets;
  final bool sender;

  GroupMessageBubble({
    this.timestamp,
    this.time,
    this.message,
    this.messageId,
    this.visibility,
    this.assets,
    this.usernameOfSender,
    this.sender,
  });

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

  @override
  Widget build(BuildContext context) {
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
                  if (sender)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'You',
                        style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 11,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                if (visibility)
                  Padding(
                    padding: sender
                        ? EdgeInsets.only(left: screenWidth * 0.2)
                        : EdgeInsets.only(right: screenWidth * 0.2),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: sender
                          ? Colors.indigoAccent
                          : Colors.black87, //Color(0xff5ddef4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        child: sender
                            ? FocusedMenuHolder(
                                duration: Duration(milliseconds: 100),
                                menuItemExtent:
                                    MediaQuery.of(context).size.height * 0.05,
                                blurBackgroundColor: Colors.grey[600],
                                blurSize: 0,
                                menuWidth:
                                    MediaQuery.of(context).size.width * 0.3,
                                // duration: Duration(milliseconds: 50),
                                onPressed: () {},
                                menuItems: <FocusedMenuItem>[
                                  FocusedMenuItem(
                                      title: Text(
                                        'Unsend',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {},
                                      backgroundColor: Colors.redAccent,
                                      trailingIcon: Icon(
                                        Icons.delete,
                                        size: screenWidth * 0.05,
                                        color: Colors.white,
                                      ))
                                ],
                                child: Text(
                                  message,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Montserrat'),
                                ),
                              )
                            : Text(
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
                        ? Colors.indigoAccent
                        : Colors.black87, //Color(0xff5ddef4),
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
