import 'package:Inbox/components/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class LoadingContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    double screenHeight = screenSize.dividingHeight();
    double screenWidth = screenSize.dividingWidth();
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, int index) {
          return ListTile(
            leading: SkeletonAnimation(
              curve: Curves.fastOutSlowIn,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: screenHeight * 42,
              ),
            ),
            title: SkeletonAnimation(
              curve: Curves.fastOutSlowIn,
              child: Container(
                height: screenHeight * 20,
                width: (screenW * 0.4) - (screenHeight * 42),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
            ),
            subtitle: SkeletonAnimation(
              curve: Curves.fastOutSlowIn,
              child: Container(
                height: screenHeight * 20,
                width: (screenW * 0.6) - (screenHeight * 42),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
            ),
          );
        },
      ),
    );
  }
}
