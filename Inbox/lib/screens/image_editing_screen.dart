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
  final Function(File) onPressed;
  const MediaPacket(this.file, this.onPressed, {Key key}) : super(key: key);

  Widget getAssetHolder() {
    if (FileManager.isImage(file)) {
      return Image.file(
        file,
        fit: BoxFit.fill,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize scale = ScreenSize(context: context);
    return Container(
      width: scale.horizontal(10),
      height: scale.vertical(6),
      child: InkWell(
        onTap: onPressed != null ? onPressed : () => {},
      ),
    );
  }
}
