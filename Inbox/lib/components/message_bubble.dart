import 'package:Inbox/helpers/firestore.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool sender;
  final String time;
  final String myMessageId;
  final String ontherId;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;

  MessageBubble({
    this.message,
    this.sender,
    this.time,
    this.myMessageId,
    this.ontherId,
    this.senderId,
    this.receiverId,
    this.timestamp,
  });

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

  _showDialog(parentContext) async {
    // flutter defined function
    return showDialog(
      context: parentContext,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Error",
            style: TextStyle(color: Colors.red, fontFamily: 'Mulish'),
          ),
          content: Text(
            "Unable to delete message after 5 minutes",
            style: TextStyle(
                color: Colors.grey[700], fontFamily: 'Mulish', fontSize: 14),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.grey[800], fontFamily: 'Mulish'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onPressUnsendButton(BuildContext context) {
    Duration min;
    Duration compare;
    final dateTimeNow = DateTime.now();
    compare = dateTimeNow.difference(timestamp);
    min = Duration(minutes: 5);

    if (compare < min) {
      unsendMessage();
    } else {
      _showDialog(context);
    }
  }

  unsendMessage() async {
    // final receiverCollectionRef = FirebaseFirestore.instance
    //     .collection('users/' + receiverId + '/friends/$senderId/messages');
    // await receiverCollectionRef.doc(ontherId).delete();
    // final senderCollectionRef = FirebaseFirestore.instance
    //     .collection('users/$senderId/friends/$receiverId/messages');
    // await senderCollectionRef.doc(myMessageId).delete();
    await FireStore.unsendMessage(senderId, receiverId, myMessageId, ontherId);
  }

  @override
  Widget build(BuildContext context) {
    // final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 12, bottom: 4, left: 8),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                              onPressed: () {
                                onPressUnsendButton(context);
                              },
                              backgroundColor: Colors.redAccent,
                              trailingIcon: Icon(
                                Icons.delete,
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
          // if (sender)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 6),
              child: Text(
                getDateFormat(),
                style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontFamily: 'Montserrat'),
              ))
        ],
      ),
    );
  }
}
