import 'dart:io';

import 'package:Inbox/components/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url, asset;
  final File file;
  final Future<ClosedCaptionFile> closedCaptionFile;
  final VideoPlayerOptions videoPlayerOptions;
  final double width, height;
  final VideoFormat formatHint;
  final Function onDispose;
  VideoPlayerWidget(
      {Key key,
      this.asset,
      this.closedCaptionFile,
      this.file,
      this.height,
      this.url,
      this.videoPlayerOptions,
      this.formatHint,
      this.onDispose,
      this.width})
      : super(key: key);
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  void assignVideoController(VideoPlayerWidget widget) {
    if (widget.url != null) {
      _controller = VideoPlayerController.network(widget.url,
          formatHint: widget.formatHint,
          closedCaptionFile: widget.closedCaptionFile,
          videoPlayerOptions: widget.videoPlayerOptions);
    } else if (widget.file != null) {
      _controller = VideoPlayerController.file(widget.file,
          closedCaptionFile: widget.closedCaptionFile,
          videoPlayerOptions: widget.videoPlayerOptions);
    } else if (widget.asset != null) {
      _controller = VideoPlayerController.asset(widget.asset,
          closedCaptionFile: widget.closedCaptionFile,
          videoPlayerOptions: widget.videoPlayerOptions);
    }
  }

  @override
  void initState() {
    assignVideoController(widget);
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.onDispose();
    super.dispose();
  }

  double heightOfVideoPlayer(double width) {
    /**
     * aspect ration = width/height
     * height = width/aspect_ratio
     */
    return width / _controller.value.aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize scale = ScreenSize(context: context);
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: scale.horizontal(100),
                    height: scale.vertical(60),
                    child: VideoPlayer(_controller),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
