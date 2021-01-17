import 'dart:io';

import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:flutter/material.dart';

class FileMediaPacket extends StatelessWidget {
  final File file;
  final Function onTap;
  final bool active;
  const FileMediaPacket({this.file, this.onTap, this.active});

  Widget mediaWidget() {
    var mime = FileManager.getMimeType(file);
    if (mime.contains("image")) {
      return Image.file(file, fit: BoxFit.fill);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize scale = ScreenSize(context: context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: scale.horizontal(16),
        height: scale.vertical(5.5),
        margin: EdgeInsets.symmetric(horizontal: scale.horizontal(0.4)),
        decoration: BoxDecoration(
            border:
                Border.all(width: active ? 3.0 : 0.0, color: Colors.blue[400])),
        child: mediaWidget(),
      ),
    );
  }
}
