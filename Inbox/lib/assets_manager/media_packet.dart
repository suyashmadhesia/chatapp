import 'dart:io';

import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/components/video_component.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:flutter/material.dart';

class FileMediaPacket extends StatelessWidget {
  final File file;
  final Function onTap;
  final bool active;
  FileMediaPacket({this.file, this.onTap, this.active});
  double width, height;

  Widget mediaWidget() {
    var mime = FileManager.getMimeType(file);
    if (mime.contains("image")) {
      return Image.file(file, fit: BoxFit.fill);
    } else if (mime.contains("video")) {
      return Stack(
        children: [
          VideoPlayerWidget(
            file: file,
          ),
          SizedBox(
            // width: width,
            // height: height,
            child: Container(
              width: width,
              height: height,
              color: Colors.grey[400].withOpacity(0.4),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize scale = ScreenSize(context: context);
    width = scale.horizontal(16);
    height = scale.vertical(8.5);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(horizontal: scale.horizontal(0.4)),
        decoration: BoxDecoration(
            border:
                Border.all(width: active ? 3.0 : 0.0, color: Colors.blue[400])),
        child: mediaWidget(),
      ),
    );
  }
}
