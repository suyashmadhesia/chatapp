 // _showDialog(parentContext) async {
  //   // flutter defined function
  //   return showDialog(
  //     context: parentContext,
  //     builder: (context) {
  //       // return object of type Dialog
  //       return AlertDialog(
  //         title: Text(
  //           "Error",
  //           style: TextStyle(color: Colors.red, fontFamily: 'Mulish'),
  //         ),
  //         content: Text(
  //           "Unable to delete message after 1 hours",
  //           style: TextStyle(
  //               color: Colors.grey[700], fontFamily: 'Mulish', fontSize: 14),
  //         ),
  //         actions: <Widget>[
  //           // usually buttons at the bottom of the dialog
  //           FlatButton(
  //             child: new Text(
  //               "OK",
  //               style: TextStyle(color: Colors.grey[800], fontFamily: 'Mulish'),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void onPressUnsendButton(BuildContext context) {
  //   Duration min;
  //   Duration compare;
  //   final dateTimeNow = DateTime.now();
  //   compare = dateTimeNow.difference(timestamp);
  //   min = Duration(minutes: 60);

  //   if (compare < min) {
  //     unsendMessage();
  //   } else {
  //     _showDialog(context);
  //   }
  // }