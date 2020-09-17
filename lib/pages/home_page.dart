import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/common/main_custom_app_bar.dart';
import 'package:photonix_app/model/Authentication.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/chat.dart';
import 'package:photonix_app/pages/complete_signup.dart';
import 'package:photonix_app/pages/newsfeed.dart';
import 'package:photonix_app/pages/notification.dart';
import 'package:photonix_app/pages/trending.dart';
import 'package:photonix_app/pages/upload_post_image_page.dart';
import 'package:photonix_app/styles/colors.dart';

import 'create_username.dart';

final StorageReference storageReference =
    FirebaseStorage.instance.ref().child("post_images");
final StorageReference profilePicReference =
    FirebaseStorage.instance.ref().child("profile_pictures");
final CollectionReference postReference =
    Firestore.instance.collection('posts');
final CollectionReference userReference =
    Firestore.instance.collection('users');
final CollectionReference activityFeedReference =
    Firestore.instance.collection("feed");
final CollectionReference commentsReference =
    Firestore.instance.collection("comments");
final CollectionReference followersReference =
    Firestore.instance.collection("followers");
final CollectionReference followingReference =
    Firestore.instance.collection("following");
final CollectionReference timelineReference =
    Firestore.instance.collection("timeline");

final DateTime timestamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEmailVerified;
  bool _isSignedIn = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  Auth _auth = Auth();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int _currentIndex = 0;

  final PageStorageBucket bucket = PageStorageBucket();
  PageController pageController =
      PageController(initialPage: 0, keepPage: true);

  @override
  void initState() {
    super.initState();
    auth.currentUser().then((user) {
      if (user != null) {
        checkEmailVerification();
        controlSingIn(user);
      }
    }).catchError((err) {
      print(err.toString());
    });
  }

  controlSingIn(FirebaseUser firebaseUser) async {
    if (firebaseUser != null) {
      await saveUserInfoToFirestore();
      setState(() {
        _isSignedIn = true;
      });
      configureRealTimePushNotification();
    } else {
      setState(() {
        _isSignedIn = false;
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => CompleteSignup()));
    }
  }

  saveUserInfoToFirestore() async {
    final FirebaseUser gCurrentUser = await auth.currentUser();
    DocumentSnapshot documentSnapshot =
        await userReference.document(gCurrentUser.uid).get();

    if (!documentSnapshot.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateUsername()));

      userReference.document(gCurrentUser.uid).setData({
        "uid": gCurrentUser.uid,
        "name": gCurrentUser.displayName,
        "username": username,
        "profilePic": "",
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp
      });
      await followersReference
          .document(gCurrentUser.uid)
          .collection("userFollowers")
          .document(gCurrentUser.uid)
          .setData({});
      documentSnapshot = await userReference.document(gCurrentUser.uid).get();
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  configureRealTimePushNotification() async {
    final FirebaseUser gUser = await auth.currentUser();

    if (Platform.isIOS) {
      getIOPermissions();
    }

    _firebaseMessaging.getToken().then((token) {
      userReference
          .document(gUser.uid)
          .updateData({"androidNotificationToken": token});
    });
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> msg) async {
      final String recipientId = msg["data"]["recipient"];
      final String body = msg["notification"]["body"];

      if (recipientId == gUser.uid) {
        SnackBar snackBar = SnackBar(
          content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  getIOPermissions() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Settings Registered: $settings");
    });
  }

  checkEmailVerification() async {
    _isEmailVerified = await _auth.isEmailVerified();
    if (!_isEmailVerified) {
      await auth.signOut();
      showVerifyEmailDialog();
    }
  }

  resentVerifyEmail() {
    _auth.sendEmailVerification();
    showVerifyEmailSentDialog();
  }

  void showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (BuildContext ctx) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          color: Theme.of(context).accentColor,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          "Update Status",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {
                    moveToUploadPostImagePage();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.photo_camera,
                          color: Theme.of(context).accentColor,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          "Upload Photo",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.videocam,
                          color: Theme.of(context).accentColor,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          "Upload Video",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.poll,
                          color: Theme.of(context).accentColor,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          "Create Poll",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                )
              ],
            ),
          );
        });
  }

  pageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      _currentIndex = index;
      pageController.animateToPage((index),
          duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  buildHomeScreen() {
    return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56.0),
          child: MainCustomAppBar(),
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (index) {
            pageChanged(index);
          },
          children: <Widget>[
            NewsFeedPage(
              fCurrentUser: currentUser,
            ),
            TrendingPage(),
            ChatPage(),
            NotificationPage(
              fCurrentUser: currentUser,
            )
          ],
        ),
        /*PageStorage(
          child: _currentPage,
          bucket: bucket,
        ),*/
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 40.0,
          ),
          onPressed: () {
            showBottomSheet(context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          elevation: 8.0,
          shape: CircularNotchedRectangle(),
          child: Container(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
              height: 56.0,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: MaterialButton(
                            onPressed: () {
                              setState(() {
                                _currentIndex = 0;
                              });
                              bottomTapped(0);
                            },
                            minWidth: 40.0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: _currentIndex == 0 ? 56.0 : 40.0,
                              height: double.maxFinite,
                              decoration: _currentIndex == 0
                                  ? BoxDecoration(
                                      color: firstColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(16.0)))
                                  : null,
                              child: Container(
                                child: IconTheme(
                                  data: IconThemeData(
                                      size: 24.0,
                                      color: _currentIndex == 0
                                          ? Colors.white
                                          : Theme.of(context).accentColor),
                                  child: Icon(Icons.home),
                                ),
                              ),
                            )),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                          bottomTapped(1);
                        },
                        minWidth: 40.0,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: _currentIndex == 1 ? 56.0 : 40.0,
                          height: double.maxFinite,
                          decoration: _currentIndex == 1
                              ? BoxDecoration(
                                  color: firstColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)))
                              : null,
                          child: Container(
                            child: IconTheme(
                              data: IconThemeData(
                                  size: 24.0,
                                  color: _currentIndex == 1
                                      ? Colors.white
                                      : Theme.of(context).accentColor),
                              child: Icon(Icons.trending_up),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 2;
                          });
                          bottomTapped(2);
                        },
                        minWidth: 40.0,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: _currentIndex == 2 ? 56.0 : 40.0,
                          height: double.maxFinite,
                          decoration: _currentIndex == 2
                              ? BoxDecoration(
                                  color: firstColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)))
                              : null,
                          child: Container(
                            child: IconTheme(
                              data: IconThemeData(
                                  size: 24.0,
                                  color: _currentIndex == 2
                                      ? Colors.white
                                      : Theme.of(context).accentColor),
                              child: Icon(Icons.send),
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 3;
                          });
                          bottomTapped(3);
                        },
                        minWidth: 40.0,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: _currentIndex == 3 ? 56.0 : 40.0,
                          height: double.maxFinite,
                          decoration: _currentIndex == 3
                              ? BoxDecoration(
                                  color: firstColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0)))
                              : null,
                          child: Container(
                            child: IconTheme(
                              data: IconThemeData(
                                  size: 24.0,
                                  color: _currentIndex == 3
                                      ? Colors.white
                                      : Theme.of(context).accentColor),
                              child: Icon(Icons.notifications),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ));
  }

  buildWaitingScreen() {
    return Scaffold(
      body: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isSignedIn ? buildHomeScreen() : buildWaitingScreen();
  }

  moveToUploadPostImagePage() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UploadPostImagePage(
                  fCurrentUser: currentUser,
                )));
  }

  moveToCompleteSignupPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => CompleteSignup()));
  }
}
