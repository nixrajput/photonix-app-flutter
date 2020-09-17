import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as ImageD;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/styles/colors.dart';
import 'package:photonix_app/styles/text_styles.dart';
import 'package:uuid/uuid.dart';

import 'home_page.dart';

class UploadPostImagePage extends StatefulWidget {
  final User fCurrentUser;

  UploadPostImagePage({Key key, this.fCurrentUser}) : super(key: key);

  @override
  _UploadPostImagePageState createState() => _UploadPostImagePageState();
}

class _UploadPostImagePageState extends State<UploadPostImagePage>
    with AutomaticKeepAliveClientMixin<UploadPostImagePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _imageURI;
  bool _isUploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController locationTextController = TextEditingController();
  String gettingLoc = "";

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
              backgroundColor: Theme.of(context).canvasColor),
          iosUiSettings: IOSUiSettings(
            title: "Crop Image",
            minimumAspectRatio: 1.0,
          ));

      setState(() {
        _imageURI = croppedFile;
      });
    }
  }

  clearPostInfo() {
    descriptionTextController.clear();
    locationTextController.clear();
    setState(() {
      _imageURI = null;
    });
  }

  compressingImage() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImageD.Image mImageFile = ImageD.decodeImage(_imageURI.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImageD.encodeJpg(mImageFile, quality: 100));
    setState(() {
      _imageURI = compressedImageFile;
    });
  }

  uploadAndSave() async {
    setState(() {
      _isUploading = true;
    });

    await compressingImage();

    String imageUrl = await uploadPhoto(_imageURI);
    savePostInfoToDatabase(
        url: imageUrl,
        location: locationTextController.text,
        description: descriptionTextController.text);

    locationTextController.clear();
    descriptionTextController.clear();

    setState(() {
      _imageURI = null;
      _isUploading = false;
      postId = Uuid().v4();
    });

    SnackBar snackBar = SnackBar(content: Text("Image Uploaded Successfully"));
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }

  savePostInfoToDatabase({String url, String location, String description}) {
    postReference
        .document(widget.fCurrentUser.uid)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.fCurrentUser.uid,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.fCurrentUser.username,
      "location": location,
      "description": description,
      "url": url
    });
  }

  getUserCurrentLocation() async {
    setState(() {
      gettingLoc = "Getting location...";
    });
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placeMarks[0];
    /*String completeAddressInfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
        '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
        '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, '
        '${mPlaceMark.postalCode} ${mPlaceMark.country}';*/
    String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextController.text = specificAddress;
    setState(() {
      gettingLoc = "";
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask _uploadStorageTask = storageReference
        .child(widget.fCurrentUser.uid)
        .child("post$postId.jpg")
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
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  clearPostInfo();
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
                      "Select Image To Post",
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
              )
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
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            GestureDetector(
                                onTap: () {
                                  clearPostInfo();
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
                      "Upload Picture",
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: height / 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: height / 40, vertical: height / 60),
                          color: firstColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          onPressed: getUserCurrentLocation,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 18.0,
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                "Get Location",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: height / 55,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        RaisedButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: height / 15, vertical: height / 60),
                          onPressed: _isUploading ? null : uploadAndSave,
                          color: secondColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Text(
                            "SHARE",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: height / 50,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: FileImage(_imageURI), fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              widget.fCurrentUser.profilePic),
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: descriptionTextController,
                              decoration:
                                  InputDecoration(hintText: "Write caption..."),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 40.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: locationTextController,
                              decoration: InputDecoration(
                                hintText: "Location...",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    child: Text(gettingLoc),
                  ),
                ],
              ),
              SizedBox(
                height: 32.0,
              )
            ],
          ),
          showCircularProgress()
        ],
      )),
    );
  }

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return _imageURI == null ? buildUploadScreen() : displayUploadScreen();
  }
}
