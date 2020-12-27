import 'dart:async';
import 'dart:io';
import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/material.dart';
//import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

//Constant
  final _picker = ImagePicker();
  File _image;
  String profileImageId = Uuid().v4();
  String bio;
  String email;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  User user = FirebaseAuth.instance.currentUser;
  bool isUploading = false;
  final storageRefs = FirebaseStorage.instance.ref();
  final userRefs = FirebaseFirestore.instance.collection('users');

//Validators
  // final emailValidator = MultiValidator([
  //   EmailValidator(errorText: 'Invalid Email...'),
  // ]);

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

  Future<String> uploadImage(image) async {
    UploadTask uploadTask =
        storageRefs.child('profile_$profileImageId.jpg').putFile(image);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String image_field;
  String bio_field;
  String email_field;

  String deletingImgPath;

  getUserData() async {
    DocumentSnapshot doc = await userRefs.doc(user.uid).get();
    Account userData = Account.fromDocument(doc);
    image_field = userData.avtar;
    bio_field = userData.bio;
    email_field = userData.email;
  }

  removeProfile() async {
    await getUserData();
    if (image_field != '') {
      setState(() {
        isUploading = true;
      });
      deletingImgPath = image_field
          .replaceAll(
              new RegExp(
                  r'https://firebasestorage.googleapis.com/v0/b/unme-37a26.appspot.com/o/'),
              '')
          .split('?')[0];
      await storageRefs
          .child(deletingImgPath)
          .delete()
          .then((value) => print('deleted'));
      await userRefs.doc(user.uid).update({
        'avtar': '',
      });
      setState(() {
        isUploading = false;
      });

      SnackBar snackbar = SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green[700],
        content: Text('Profile Image Deleted !'),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);

      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.pop(context);
    }
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await getUserData();

    if (_image != null) {
      await compressImage();
      String mediaUrl = await uploadImage(_image);
//deleting old image profile
      if (image_field != '') {
        deletingImgPath = image_field
            .replaceAll(
                new RegExp(
                    r'https://firebasestorage.googleapis.com/v0/b/unme-37a26.appspot.com/o/'),
                '')
            .split('?')[0];
        await storageRefs
            .child(deletingImgPath)
            .delete()
            .then((value) => print('deleted'));
        await userRefs.doc(user.uid).update({
          'avtar': '',
        });
      }
      userRefs.doc(user.uid).update({
        'avtar': mediaUrl,
        'bio': bio == null || bio == '' ? bio_field : bio,
        'email': email == null || email == '' ? email_field : email,
      });
    }
    if (_image == null) {
      userRefs.doc(user.uid).update({
        'bio': bio == null || bio == '' ? bio_field : bio,
        'email': email == null || email == '' ? email_field : email,
      });
    }
    setState(() {
      isUploading = false;
    });
    SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green[700],
      content: Text('Profile Updated!'),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
              title: Text(
                'Upload Profile Image',
                style: TextStyle(color: Colors.tealAccent),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(context);
                    final pickedFile = await _picker.getImage(
                        source: ImageSource.camera,
                        maxHeight: 500,
                        maxWidth: 500);

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
                        maxHeight: 500,
                        maxWidth: 500);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: isUploading ? null : () => handleSubmit(),
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
            ),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            if (_image != null) {
              clearImage();
            }
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontSize: 20.0,
          ),
        ),
      ),
      body: Center(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            isUploading ? LinearProgressIndicator() : Text(''),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: 150,
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[600],
                    child: IconButton(
                      splashColor: Colors.grey[900],
                      splashRadius: 50.0,
                      onPressed: () => selectImage(context),
                      icon: Icon(
                        Icons.file_upload,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _image == null
                        ? 'No Image Selected, Select one !'
                        : 'Image Selected tap to change selected image',
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.0,
                        fontFamily: 'Montserrat'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        bio = value;
                      },
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
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2)),
                        hintText: 'Bio',
                        hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16.0,
                            fontFamily: 'Montserrat'),
                        helperText: 'Write something about you....',
                        helperStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.0,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      //validator: emailValidator,
                      cursorColor: Colors.grey,
                      autofocus: false,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                          fontFamily: 'Montserrat'),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2)),
                        hintText: 'Email',
                        hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16.0,
                            fontFamily: 'Montserrat'),
                        helperText: 'In case you forget your password',
                        helperStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12.0,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlatButton(
                      color: Colors.red,
                      onPressed: removeProfile,
                      child: Text('Remove Profile Image',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 10))),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
