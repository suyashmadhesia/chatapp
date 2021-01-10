import 'package:flutter/material.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}
//TODO Don't touch it i am working on it;
class _CreateGroupState extends State<CreateGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Create Group', style: TextStyle(fontFamily: 'Montserrat')),
      ),
      body: ListView(children: [
        Container(),
        ]
        ),
    );
  }
}
