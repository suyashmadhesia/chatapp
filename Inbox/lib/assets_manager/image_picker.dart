import 'dart:io';
import 'dart:typed_data';

import 'package:Inbox/assets_manager/media_packet.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/components/video_component.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:Inbox/helpers/firestore.dart';
import 'package:Inbox/models/message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageVideoPickerScreen extends StatefulWidget {
  final Function onTapBack;
  final User user;
  final List<File> files;
  final String avatar, recepient, uniqueMessageId;
  const ImageVideoPickerScreen(
      {this.onTapBack,
      this.files,
      this.user,
      this.avatar,
      this.uniqueMessageId,
      this.recepient});
  @override
  _ImageVideoPickerScreenState createState() => _ImageVideoPickerScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ImageVideoPickerScreenState extends State<ImageVideoPickerScreen> {
  List<File> medias = [];
  int currentIndex = 0;
  AppState state;

  User currentUser;

  TextEditingController captionController = TextEditingController();

  double startX, updateX;

  void deleteAsset() {
    if (widget.user == null) {
      currentUser = FirebaseAuth.instance.currentUser;
    }
    if (medias.length > 0) {
      medias.removeAt(currentIndex);
      if (currentIndex >= medias.length) {
        currentIndex = medias.length - 1;
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

  Future<void> onSendClick() async {
    List<Asset> assets = [];
    for (File media in medias) {
      Asset asset = Asset(file: media);
      asset.setContentType();
      asset.setNameGenerated();
      assets.add(asset);
    }
    FireStore.uploadAssets(
        userId: widget.user.uid,
        assets: assets,
        avatar: widget.avatar,
        message: captionController.text.isEmpty ? '' : captionController.text,
        receiverId: widget.recepient,
        userUniqueMessageId: widget.uniqueMessageId);
    widget.onTapBack();
  }

  Future<void> addAsset() async {
    List<String> exts = [
      'png',
      'apng',
      'jpg',
      'jpeg',
      'ico',
      'mp4',
      'mov',
      'wmv',
      'flv',
      'avi',
      'avchd',
      'webm',
      'mkv'
    ];
    List<File> pickedFiles = await FileManager.pickFiles(
        allowMultiple: true,
        allowedExtensions: exts,
        fileType: FileType.custom);
    setState(() {
      medias.addAll(pickedFiles);
    });
  }

  @override
  void initState() {
    if (widget.files != null) {
      medias = widget.files;
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
        sourcePath: medias[currentIndex].path,
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
      medias[currentIndex] = croppedFile;
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
          onPressed: widget.onTapBack != null
              ? widget.onTapBack
              : () => {Navigator.of(context).pop()},
        ),
        actions: [
          if (medias.length > 1)
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                onPressed: deleteAsset),
          if (medias.length > 1 &&
              FileManager.getMimeType(medias[currentIndex]).contains("image"))
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
              child: (medias.isEmpty)
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
                            medias.length > currentIndex + 1)
                          {
                            setState(() => {currentIndex += 1})
                          }
                        else if (updateX - startX > 0 &&
                            medias.length > 0 &&
                            currentIndex - 1 >= 0)
                          {
                            setState(() => {currentIndex -= 1})
                          }
                      },
                      child: Container(
                          color: Colors.white,
                          child: FileManager.getMimeType(medias[currentIndex])
                                  .contains("video")
                              ? VideoPlayerWidget(
                                  file: medias[currentIndex],
                                )
                              : Image.file(
                                  medias[currentIndex],
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
                                onPressed: onSendClick),
                            hintText: 'Add Caption',
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    ),
                    if (medias.length > 0)
                      Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: medias.length,
                              itemBuilder: (context, index) => FileMediaPacket(
                                    file: medias[index],
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
