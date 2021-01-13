import 'dart:io';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageEditingScreen extends StatefulWidget {
  final List<File> files;
  const ImageEditingScreen(this.files);
  @override
  _ImageEditingScreenState createState() => _ImageEditingScreenState();
}

class _ImageEditingScreenState extends State<ImageEditingScreen> {
  List<File> images = [];
  File currentFile;

  void onNoImageFiles() {}

  void filterImageFiles() {
    images = widget.files.where((element) => FileManager.isImage(element));
    if (images.isEmpty) {
      onNoImageFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MediaPacket extends StatelessWidget {
  final File file;
  const MediaPacket(this.file, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ScreenSize scale = ScreenSize(context: context);
    return Container();
  }
}
