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

  Future<File> getFile() async {
    await setMediaPath();
    if (widget.asset.file != null) {
      return widget.asset.file;
    }
    bool exist = await File(mediaPath).exists();
    if (!exist) {
      // Start downloading file
      File file = await FileManager.downloadFile(
          widget.asset.url,
          (widget.sent)
              ? '/media/sent/${widget.asset.name}'
              : '/media/${widget.asset.name}');
      return file;
    }

    return File(mediaPath);
  }

  Widget mediaWidget(bool loading) {
    /* If Media is not present in folder show thumbnail and ask for download
    download it then show media from folder.
    */
    return FutureBuilder(
      future: getFile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        bool isDone = snapshot.connectionState == ConnectionState.done;
        // If Image
        if (widget.asset.contentType.contains("image")) {
          return isDone
              ? Image.file(
                  snapshot.data,
                  fit: BoxFit.fill,
                )
              : Image.network(
                  widget.asset.thumbnail,
                  fit: BoxFit.fill,
                );
        } else if (widget.asset.contentType.contains("video")) {
          VideoPlayerController controller =
              VideoPlayerController.network(widget.asset.thumbnail);
          return SizedBox(
            width: scale.horizontal(40),
            child: VideoPlayer(controller),
          );
        } else if (widget.asset.contentType.contains("audio")) {}
      },
    );
  }

  Widget uploadingWidget() {
    return FutureBuilder(
      future: widget.asset.task,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // File uploaded now show the image
          return Container(
              width: scale.horizontal(50), child: mediaWidget(false));
        } else {
          return InkWell(
            onTap: () {
              widget.asset.task.cancel();
              state.popAssetUsingHash(
                  widget.receiverId, widget.messageHash, widget.asset);
            },
            child: Container(
              width: scale.horizontal(50),
              child: mediaWidget(true),
            ),
          );
        }
      },
    );
  }

  double width, height;
  @override
  Widget build(BuildContext context) {
    scale = ScreenSize(context: context);
    return uploadingWidget();
  }
}
