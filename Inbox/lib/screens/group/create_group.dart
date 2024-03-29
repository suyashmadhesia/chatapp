import 'dart:io';
// import 'package:Inbox/helpers/send_notification.dart';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/helpers/send_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:Inbox/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {

  final String username;
CreateGroup({this.username});

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  @override
  void initState() {
    super.initState();
  }

//validators
  final groupNameValidator = MultiValidator([
    RequiredValidator(errorText: 'Group Name is required'),
    MinLengthValidator(4,
        errorText: 'Group Name must be at least 4 characters'),
    MaxLengthValidator(14,
        errorText: 'Group Name must be less than 14 characters')
  ]);

  final groupDescriptionValidator = MultiValidator([
    RequiredValidator(errorText: 'Group Description is required'),
    MinLengthValidator(4,
        errorText: 'Group Description must be at least 4 characters'),
  ]);

//variables

  double screenHeight;
  double screenWidth;
  String groupName;
  String description;
  bool isUploading = false;
  bool isImageLoaded = false;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File _image;
  String profileImageId = Uuid().v4();
  final collectionRefs = FirebaseFirestore.instance;
  final storageRefs = FirebaseStorage.instance.ref();
  final currentUserId = FirebaseAuth.instance.currentUser.uid;
  String groupId = Uuid().v4();
  List groupList = [];

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

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    if (_image != null) {
      await compressImage();
      String medialUrl = await uploadImage(_image);
      await collectionRefs.collection('groups').doc('GROUP' + groupId).set({
        'groupId': 'GROUP' + groupId,
        'groupName': groupName,
        'groupDescription': description,
        'createdAt': DateTime.now(),
        'messageAt': DateTime.now(),
        'lastMessage': 'You have joined this group',
        'groupBanner': medialUrl,
        'groupMember': [currentUserId],
        'adminsId': [currentUserId],
      });
      await collectionRefs
          .collection('groups/GROUP$groupId/members')
          .doc(currentUserId)
          .set({
        'joinAt': DateTime.now(),
        'isAdmin': true,
        'userId': currentUserId,
      });
      await collectionRefs.collection('users').doc(currentUserId).update({
        'groupsList': FieldValue.arrayUnion(['GROUP' + groupId]),
      });
      await collectionRefs
          .collection('users/$currentUserId/groups')
          .doc('GROUP' + groupId)
          .set({
        'joinedAt': DateTime.now(),
        'isMuted': false,
        'groupName': groupName,
        'isAdmin': true,
        'messageAt': DateTime.now(),
        'groupId': 'GROUP' + groupId,
      });
      setState(() {
        isUploading = true;
      });
    } else if (_image == null) {
      await collectionRefs.collection('groups').doc('GROUP' + groupId).set({
        'groupId': 'GROUP' + groupId,
        'groupName': groupName,
        'groupDescription': description,
        'createdAt': DateTime.now(),
        'messageAt': DateTime.now(),
        'lastMessage': 'You have joined this group',
        'groupBanner': '',
        'groupMember': [currentUserId],
        'adminsId': [currentUserId],
      });
      await collectionRefs
          .collection('groups/GROUP$groupId/members')
          .doc(currentUserId)
          .set({
        'joinAt': DateTime.now(),
        'isAdmin': true,
        'userId': currentUserId,
        'username' : widget.username,
      });
      await collectionRefs.collection('users').doc(currentUserId).update({
        'groupsList': FieldValue.arrayUnion(['GROUP' + groupId]),
      });
      await collectionRefs
          .collection('users/$currentUserId/groups')
          .doc('GROUP' + groupId)
          .set({
        'joinedAt': DateTime.now(),
        'isMuted': false,
        'groupName': groupName,
        'isAdmin': true,
        'messageAt': DateTime.now(),
        'groupId': 'GROUP' + groupId,
      });
      setState(() {
        isUploading = true;
      });
    }
    SendNotification().topicToSuscribe('/topics/GROUP'+groupId);
  }

  Future<String> uploadImage(image) async {
    UploadTask uploadTask =
        storageRefs.child('profile_$profileImageId.jpg').putFile(image);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
              title: Text(
                'Upload Profile Image',
                style: TextStyle(color: Colors.tealAccent[700]),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(context);
                    final pickedFile = await _picker.getImage(
                      source: ImageSource.camera,
                      maxHeight: screenHeight * 0.4,
                      maxWidth: screenWidth,
                    );

                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  },
                  //handleTakeImage,
                  child: Text('Photo with Camera'),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(context);
                    final pickedFile = await _picker.getImage(
                      source: ImageSource.gallery,
                      maxHeight: screenHeight * 0.4,
                      maxWidth: screenWidth,
                    );

                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }, //handleChooseFromGallery,
                  child: Text('Choose from Gallery'),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ]);
        });
  }

  floatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (!isUploading) {
          if (_formKey.currentState.validate()) {
            await handleSubmit();
            debugPrint('Done !');
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        }
      },
      elevation: 5,
      backgroundColor: Colors.grey[900],
      child: isUploading
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : Icon(
              Icons.done,
              color: Colors.white,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenH = MediaQuery.of(context).size.height;
    double  screenW = MediaQuery.of(context).size.width;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return Scaffold(
      floatingActionButton: floatingActionButton(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Create Group', style: TextStyle(fontFamily: 'Montserrat')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(
              height: screenHeight * 378,
              width: screenW,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: DecorationImage(
                  image: _image != null
                      ? FileImage(_image)
                      : AssetImage('assets/images/group.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    color: _image != null ? Colors.redAccent : Colors.green,
                    splashRadius: 12,
                    splashColor: Colors.white,
                    icon: _image != null
                        ? Icon(Icons.delete)
                        : Icon(Icons.upload_file),
                    onPressed: () {
                      if (!isUploading) {
                        if (_image == null) {
                          selectImage(context);
                        } else if (_image != null) {
                          clearImage();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: groupNameValidator,
                onChanged: (value) {
                  groupName = value;
                },
                cursorColor: Colors.grey,
                autofocus: false,
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                    fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  hintText: 'Group Name',
                  hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) {
                  description = value;
                },
                validator: groupDescriptionValidator,
                maxLength: 100,
                maxLines: 4,
                minLines: 1,
                cursorColor: Colors.grey,
                autofocus: false,
                style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                    fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2)),
                  hintText: 'Description',
                  hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                      fontFamily: 'Montserrat'),
                  helperText: 'Please provide description of group ....',
                  helperStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12.0,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
