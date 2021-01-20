import 'dart:io';

import 'package:Inbox/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:Inbox/screens/home.dart';

class GroupEditProfile extends StatefulWidget {
  final String groupId;
  GroupEditProfile(this.groupId);
  @override
  _GroupEditProfileState createState() => _GroupEditProfileState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _GroupEditProfileState extends State<GroupEditProfile> {
  @override
  void initState() {
    getGroupData();
    state = AppState.free;
    super.initState();
  }

//variable;
  final _picker = ImagePicker();
  AppState state;
  bool isDataLoaded = false;
  File _image;
  String profileImageId = Uuid().v4();
  String description;
  String name;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isUploading = false;
  final storageRefs = FirebaseStorage.instance.ref();
  final groupRefs = FirebaseFirestore.instance.collection('groups');
  String imageField;
  String descriptionField;
  String nameField;
  String deletingImgPath;
  bool isLoading = false;
  double screenHeight;
  double screenWidth;
  PickedFile imageFile;

  //Functions
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imagefile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImage = File('$path/img_$profileImageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imagefile, quality: 70));

    setState(() {
      _image = compressedImage;
    });
  }

  clearImage() {
    setState(() {
      _image = null;
    });
  }

  removeProfile() async {
    await getGroupData();
    if (imageField != '') {
      setState(() {
        isUploading = true;
      });
      deletingImgPath = imageField
          .replaceAll(
              new RegExp(
                  r'https://firebasestorage.googleapis.com/v0/b/unme-37a26.appspot.com/o/'),
              '')
          .split('?')[0];
      await storageRefs.child(deletingImgPath).delete();

      await groupRefs.doc(widget.groupId).update({
        'groupBanner': '',
      });
      setState(() {
        isUploading = false;
      });

      SnackBar snackbar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[700],
        content: Text(
          'Group Image Deleted !',
          style: TextStyle(color: Colors.white),
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);

      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.pop(context);
    }
  }

  getGroupData() async {
    DocumentSnapshot doc = await groupRefs.doc(widget.groupId).get();
    GroupAccount groupData = GroupAccount.fromDocument(doc);
    imageField = groupData.groupBanner;
    nameField = groupData.groupName;
    descriptionField = groupData.groupDescription;
  }

  Future<String> uploadImage(image) async {
    UploadTask uploadTask =
        storageRefs.child('profile_$profileImageId.jpg').putFile(image);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await getGroupData();

    if (_image != null) {
      await compressImage();
      String mediaUrl = await uploadImage(_image);
//deleting old image profile
      if (imageField != '') {
        deletingImgPath = imageField
            .replaceAll(
                new RegExp(
                    r'https://firebasestorage.googleapis.com/v0/b/unme-37a26.appspot.com/o/'),
                '')
            .split('?')[0];
        await storageRefs.child(deletingImgPath).delete();
        // .then((value) => print('deleted'));
        await groupRefs.doc(widget.groupId).update({
          'avtar': '',
        });
      }
      await groupRefs.doc(widget.groupId).update({
        'groupBanner': mediaUrl,
        'groupDescription': description == null || description == ''
            ? descriptionField
            : description,
        'groupName': name == null || name == '' ? nameField : name,
      });
    }
    if (_image == null) {
      await groupRefs.doc(widget.groupId).update({
        'groupDescription': description == null || description == ''
            ? descriptionField
            : description,
        'groupName': name == null || name == '' ? nameField : name,
      });
    }
    setState(() {
      isUploading = false;
    });
    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green[700],
      content: Text(
        'Profile Updated!',
        style: TextStyle(color: Colors.white),
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  loadImage(double height, double width) {
    if (imageField.isEmpty && _image == null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: DecorationImage(
            image: AssetImage('assets/images/user.png'),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (imageField.isNotEmpty && _image == null) {
      return Container(
        height: height,
        width: width,
        child: Image.network(imageField),
      );
    } else if (imageField.isNotEmpty && _image != null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: DecorationImage(
            image: FileImage(_image),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (imageField.isEmpty && _image != null) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: DecorationImage(
            image: FileImage(_image),
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }

  Future<Null> pickImageFromGallery() async {
    imageFile = await _picker.getImage(source: ImageSource.gallery);
    if(imageFile != null){
      setState(() {
        state = AppState.picked;
      });
    }
  }

   Future<Null> pickImageFromCamera() async {
    imageFile = await _picker.getImage(source: ImageSource.camera);
    if(imageFile != null){
      setState(() {
        state = AppState.picked;
      });
    }
  }

  cropImage() async{
    
  }

  Widget buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.edit);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  selectImage(parentContext) {
    return showModalBottomSheet(
        enableDrag: false,
        context: parentContext,
        builder: (builder) {
          return new Container(
            height: screenHeight * 120,
            color: Colors.white,
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: Radius.circular(screenHeight * 20),
                  topRight: Radius.circular(screenHeight * 20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Image',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                  ListTile(
                    onLongPress: (){},
                    title: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      leading: Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                  ListTile(
                    onLongPress: (){},
                    title: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      leading: Icon(Icons.image, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Container();
  }
}
