import 'dart:async';
import 'dart:io';
import 'package:Inbox/components/screen_size.dart';
import 'package:Inbox/models/user.dart';
import 'package:Inbox/screens/home.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:data_connection_checker/data_connection_checker.dart';
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

enum AppState {
  free,
  picked,
  cropped,
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    super.initState();
    state = AppState.free;
    getUserData();
  }

//Constant
  final _picker = ImagePicker();
  AppState state;
  bool isDataLoaded = false;
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

  Future<String> uploadImage(image) async {
    UploadTask uploadTask =
        storageRefs.child('profile_$profileImageId.jpg').putFile(image);
    TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String imageField;
  String bioField;
  String emailField;

  String deletingImgPath;

  getUserData() async {
    DocumentSnapshot doc = await userRefs.doc(user.uid).get();
    Account userData = Account.fromDocument(doc);
    imageField = userData.avtar;
    bioField = userData.bio;
    emailField = userData.email;
    setState(() {
      isDataLoaded = true;
    });
  }

  removeProfile() async {
    await getUserData();
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

  bool isLoading = false;

  bool isInternet = true;

  handleSubmit() async {
    if (isInternet) {
      setState(() {
        isUploading = true;
      });
      await getUserData();

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
          await userRefs.doc(user.uid).update({
            'avtar': '',
          });
        }
        userRefs.doc(user.uid).update({
          'avtar': mediaUrl,
          'bio': bio == null || bio == '' ? bioField : bio,
          'email': email == null || email == '' ? emailField : email,
        });
      }
      if (_image == null) {
        userRefs.doc(user.uid).update({
          'bio': bio == null || bio == '' || bio.isEmpty ? bioField : bio,
          'email': email == null || email == '' || email.isEmpty ? emailField : email,
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

   selectImage(parentContext) {
    return showModalBottomSheet(
        enableDrag: false,
        context: parentContext,
        builder: (builder) {
          return new Container(
            height: screenHeight * 250,
            color: Color(0xff767676),
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 4),
                        child: Text(
                          'Select Image',
                          style: TextStyle(color: Colors.black,fontSize: 18, fontFamily: 'Mulish'),
                        ),
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
                    onTap: () async{
                      await pickImageFromCamera();
                    },
                    title: Text(
                        'Camera',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      leading: Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                  ListTile(
                    onTap: () async {
                      await pickImageFromGallery();
                    },
                    title: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      leading: Icon(Icons.image, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        });
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

  double screenHeight;
  double screenWidth;

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    ScreenSize screenSize = ScreenSize(height: screenH, width: screenW);
    screenHeight = screenSize.dividingHeight();
    screenWidth = screenSize.dividingWidth();
    return 
        Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    onPressed: isUploading ? null : () => handleSubmit(),
                    icon: Icon(
                      Icons.done,
                      color: Colors.black,
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
                icon: Icon(Icons.close, color: Colors.black),
              ),
              backgroundColor: Colors.white,
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontSize: 20.0,
                ),
              ),
            ),
            body:isDataLoaded ? Center(
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  isUploading ? LinearProgressIndicator() : Text(''),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: [
                            Stack(
                              children: [
                                loadImage(screenHeight * 378, screenW),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      if (_image != null) {
                                        clearImage();
                                      } else {
                                        removeProfile();
                                        getUserData();
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.edit, color: Colors.black),
                                    onPressed: () {
                                      selectImage(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 5),
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
                ],
              ),
            ) : Center(
            child: CircularProgressIndicator(),
          ),
          );
        
  }
}
