import 'dart:io';

import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:Inbox/models/message.dart';
import 'package:Inbox/state/global.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AssetWidget extends StatefulWidget {
  final Asset asset;
  final Function onTap;
  // final Function onCancel;
  final bool uploading;
  final String receiverId;
  final int messageHash;
  // Asset was sent or received
  final bool sent;
  AssetWidget(this.asset,
      {this.onTap,
      this.uploading,
      this.receiverId,
      this.messageHash,
      this.sent = true});

  @override
  _AssetWidgetState createState() => _AssetWidgetState();
}

class _AssetWidgetState extends State<AssetWidget> {
  /*
    This Widget will show circular loader with cancel button if asset is uplaoding
    or downloading using FutureBuilder

    First we have to work on uplaoding assets
    Image and video will have same type of uplaoding preview

    While Audio and document will have nearly same type of preview

    TODO
    Upon complete of task the message will be removed from global state
   */
  ScreenSize scale;
  GlobalState state = GlobalState();

  bool isUploading() {
    return widget.uploading && widget.asset.task != null;
  }

  String mediaPath;

  Future<void> setMediaPath() async {
    String path = await FileManager.getDirPath();
    path = '/media/' + (widget.sent ? 'sent' : '');
    setState(() {
      mediaPath = path;
    });
  }

  Future<bool> fileExist() async {
    await setMediaPath();

    String mediaPath = await FileManager.getDirPath();
    mediaPath +=
        (widget.sent) ? '/sent/${widget.asset.name}' : '/${widget.asset.name}';
    bool exist = await File(mediaPath).exists();
  }

  Future<File> getFile() async {
    if (widget.asset.file != null) {
      return widget.asset.file;
    }

    // print(exist.toString() +
    //     ' ' +
    //     widget.sent.toString() +
    //     " " +
    //     mediaPath +
    //     " " +
    //     widget.asset.name);
    if (!await fileExist()) {
      // Start downloading file
      File file = await FileManager.downloadFile(
          widget.asset.url,
          (widget.sent)
              ? '/sent/${widget.asset.name}'
              : '/${widget.asset.name}');
      return file;
    }

    return File(mediaPath);
  }

  Widget completedMediaWidget() {
    if (widget.asset.contentType.contains("image")) {
      // getFile();
      return Container(
        width: scale.horizontal(50),
        // height: scale.vertical(20),
        child: Image.network(
          widget.asset.thumbnail,
          fit: BoxFit.fill,
        ),
      );
    }
  }

  Widget mediaWidget() {
    Future queue = fileExist();
    return FutureBuilder(
        future: queue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
          } else {
            return Container(
              width: scale.horizontal(40),
              // height: scale.vertical(20),
              child: Stack(
                children: [
                  Image.network(
                    widget.asset.thumbnail,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: scale.horizontal(40),
                    // height: double.maxFinite,
                    color: Colors.black.withOpacity(0.2),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: IconButton(
                            icon: Icon(
                              Icons.download_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: null),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
        });
  }

  double width, height;
  @override
  Widget build(BuildContext context) {
    scale = ScreenSize(context: context);
    if (widget.asset.file != null) {
      return Image.file(widget.asset.file);
    }
    return mediaWidget();
  }
}
