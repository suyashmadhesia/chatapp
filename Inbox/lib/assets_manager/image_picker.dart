import 'dart:io';

import 'package:Inbox/assets_manager/media_packet.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:Inbox/models/message.dart';
import 'package:Inbox/modules/text_formatter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerScreen extends StatefulWidget {
  final Function onTapBack;
  final User user;
  final List<File> files;
  final String avatar, recepient;
  const ImagePickerScreen(
      {this.onTapBack, this.files, this.user, this.avatar, this.recepient});
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  List<File> images = [];
  int currentIndex = 0;
  AppState state;

  TextEditingController captionController = TextEditingController();

  double startX, updateX;

  void deleteAsset() {
    if (images.length > 0) {
      images.removeAt(currentIndex);
      if (currentIndex >= images.length) {
        currentIndex = images.length - 1;
      }
      setState(() {});
    }
  }

  void onCropClick() {
    _cropImage();
  }

  void onTapMediaPacket(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> sendMessage() async {}

  Future<void> addAsset() async {
    List<File> pickedFiles =
        await FileManager.pickFiles(fileType: FileType.image);
    setState(() {
      images.addAll(pickedFiles);
    });
  }

  @override
  void initState() {
    if (widget.files != null) {
      images = widget.files;
    }
    state = AppState.free;
    super.initState();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: images[currentIndex].path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      images[currentIndex] = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize scale = ScreenSize(context: context);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: widget.onTapBack != null ? widget.onTapBack : () => {},
        ),
        actions: [
          if (images.length > 1)
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                onPressed: deleteAsset),
          IconButton(
              icon: Icon(
                Icons.crop,
                color: Colors.black,
              ),
              onPressed: onCropClick)
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: scale.vertical(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: scale.horizontal(100),
              height: scale.vertical(60),
              color: Colors.white,
              child: (images.isEmpty)
                  ? null
                  : GestureDetector(
                      onHorizontalDragStart: (detail) => {
                        // print(detail.globalPosition.dx.),
                        setState(() => {startX = detail.globalPosition.dx})
                      },
                      onHorizontalDragUpdate: (detail) =>
                          {updateX = detail.globalPosition.dx},
                      onHorizontalDragEnd: (detail) => {
                        if (updateX - startX < 0 &&
                            images.length > currentIndex + 1)
                          {
                            setState(() => {currentIndex += 1})
                          }
                        else if (updateX - startX > 0 &&
                            images.length > 0 &&
                            currentIndex - 1 >= 0)
                          {
                            setState(() => {currentIndex -= 1})
                          }
                      },
                      child: Container(
                          child: Image.file(
                        images[currentIndex],
                        fit: BoxFit.fill,
                      )),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(top: scale.vertical(1)),
              child: Container(
                height: scale.vertical(18),
                color: Colors.white,
                padding:
                    EdgeInsets.symmetric(horizontal: scale.horizontal(1.5)),
                child: Column(
                  children: [
                    Container(
                      width: scale.horizontal(100),
                      margin: EdgeInsets.only(bottom: scale.vertical(2)),
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (key) => print(key),
                        child: TextField(
                          controller: captionController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintStyle: TextStyle(color: Colors.black),
                              counterStyle: TextStyle(color: Colors.black),
                              prefixIcon: IconButton(
                                  icon: Icon(
                                    Icons.add_box,
                                    size: 32,
                                    color: Colors.pink[400],
                                  ),
                                  onPressed: () => {addAsset()}),
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    size: 32,
                                    color: Colors.pink[300],
                                  ),
                                  onPressed: () => {sendMessage()}),
                              hintText: 'Add Caption',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                      ),
                    ),
                    if (images.length > 0)
                      Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) => FileMediaPacket(
                                    file: images[index],
                                    active: currentIndex == index,
                                    onTap: () => {onTapMediaPacket(index)},
                                  )))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
