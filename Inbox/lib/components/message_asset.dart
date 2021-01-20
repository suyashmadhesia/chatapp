import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/models/message.dart';
import 'package:flutter/material.dart';

class MessageAsset extends StatefulWidget {
  final Asset asset;
  final Widget child;
  // Whether child is bar or rectangle
  final bool bar;
  MessageAsset({this.asset, this.child, this.bar = false});
  @override
  _MessageAssetState createState() => _MessageAssetState();
}

class _MessageAssetState extends State<MessageAsset> {
  ScreenSize scale;

  bool showUploading() {
    // returns true if assset i uploading
    // if uploading show black thumbnail and uploading loader along with cancel button
    return (widget.asset.url == null &&
        widget.asset.file != null &&
        widget.asset.task != null);
  }

  Widget uploadingWidget() {
    if (widget.bar) {
      return ListTile(
        leading: CircularProgressIndicator(
          strokeWidth: 2,
        ),
        title: widget.child,
      );
    } else {
      return Container(
        width: scale.horizontal(40),
        child: Stack(
          children: [
            widget.child,
            Container(
              color: Colors.grey[850].withOpacity(0.4),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    scale = ScreenSize(context: context);
    return Container();
  }
}
