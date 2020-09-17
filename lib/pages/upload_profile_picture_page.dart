import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as ImageD;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/styles/colors.dart';
import 'package:photonix_app/styles/text_styles.dart';
import 'package:uuid/uuid.dart';

class UploadProfilePicturePage extends StatefulWidget {
  @override
  _UploadProfilePicturePageState createState() =>
      _UploadProfilePicturePageState();
}

class _UploadProfilePicturePageState extends State<UploadProfilePicturePage>
    with AutomaticKeepAliveClientMixin<UploadProfilePicturePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _imageURI;
  bool _isUploading = false;
  String userImageId = Uuid().v4();

  @override
  void initState() {
    super.initState();
  }

  getImage(ImageSource source) async {
    PickedFile imageFile = await ImagePicker.platform.pickImage(source: source);
    if (imageFile != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Theme.of(context).canvasColor,
            toolbarTitle: "Crop Image",
            backgroundColor: Theme.of(context).canvasColor,
          ),
          iosUiSettings: IOSUiSettings(
            title: "Crop Image",
            minimumAspectRatio: 1.0,
          ));

      setState(() {
        _imageURI = croppedFile;
      });
    }
  }

  removeImage() {
    setState(() {
      _imageURI = null;
    });
  }

  compressingImage() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImageD.Image mImageFile = ImageD.decodeImage(_imageURI.readAsBytesSync());
    final compressedImageFile = File('$path/img_$userImageId.jpg')
      ..writeAsBytesSync(ImageD.encodeJpg(mImageFile, quality: 100));
    setState(() {
      _imageURI = compressedImageFile;
    });
  }

  uploadAndSave() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _isUploading = true;
    });

    await compressingImage();

    String imageUrl = await uploadPhoto(_imageURI);
    userReference.document(currentUser.uid).updateData({
      'profilePic': imageUrl,
    });

    UserUpdateInfo info = UserUpdateInfo();
    info.photoUrl = imageUrl;
    user.updateProfile(info);

    setState(() {
      _imageURI = null;
      _isUploading = false;
    });

    SnackBar snackBar = SnackBar(content: Text("Image Uploaded Successfully"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask _uploadStorageTask = profilePicReference
        .child(currentUser.uid)
        .child("profile_pic_$userImageId.jpg")
        .putFile(mImageFile);
    StorageTaskSnapshot _taskSnapshot = await _uploadStorageTask.onComplete;
    String downloadUrl = await _taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Widget showCircularProgress() {
    if (_isUploading) {
      return Container(
        color: Theme.of(context).canvasColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondColor)),
        ),
      );
    }
    return Center();
  }

  buildUploadScreen() {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              removeImage();
                              Navigator.of(context).pop();
                            },
                            child: Icon(FontAwesomeIcons.arrowAltCircleLeft,
                                color: Theme.of(context).accentColor)),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                child: Text(
                  "Choose Profile Picture",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: height / 35,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 72.0),
              Icon(
                Icons.add_photo_alternate,
                color: Colors.grey,
                size: 280.0,
              ),
              SizedBox(height: 60.0),
              Container(
                width: 200.0,
                child: RaisedButton(
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                  child: Text(
                    "CAMERA",
                    style: solidButtonTextStyle,
                  ),
                  color: firstColor,
                  padding: EdgeInsets.all(12.0),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 200.0,
                child: RaisedButton(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  child: Text(
                    "GALLERY",
                    style: solidButtonTextStyle,
                  ),
                  color: secondColor,
                  padding: EdgeInsets.all(12.0),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  displayUploadScreen() {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                            onTap: () {
                              removeImage();
                              Navigator.of(context).pop();
                            },
                            child: Icon(FontAwesomeIcons.arrowAltCircleLeft,
                                color: Theme.of(context).accentColor)),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                child: Text(
                  "Upload Profile Picture",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: height / 35,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 48.0),
              Container(
                width: 360.0,
                height: 360.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: FileImage(_imageURI), fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 48.0),
              Container(
                width: 200.0,
                child: RaisedButton(
                  onPressed: _isUploading ? null : uploadAndSave,
                  child: Text(
                    "UPLOAD",
                    style: solidButtonTextStyle,
                  ),
                  color: secondColor,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
          showCircularProgress()
        ],
      )),
    );
  }

  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return _imageURI == null ? buildUploadScreen() : displayUploadScreen();
  }
}
