import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photonix_app/common/custom_counter.dart';
import 'package:photonix_app/common/post_tile_widget.dart';
import 'package:photonix_app/common/post_widget.dart';
import 'package:photonix_app/common/rounded_network_image.dart';
import 'package:photonix_app/model/Authentication.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/complete_signup.dart';
import 'package:photonix_app/pages/edit_user_profile_page.dart';
import 'package:photonix_app/pages/followers_page.dart';
import 'package:photonix_app/pages/following_page.dart';
import 'package:photonix_app/pages/settings.dart';
import 'package:photonix_app/pages/upload_profile_picture_page.dart';
import 'package:photonix_app/styles/colors.dart';
import 'package:photonix_app/styles/text_styles.dart';

import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.uid;
  bool isLoading = false;
  Auth auth = Auth();

  List<Post> postList = [];
  String postOrientation = "grid";
  int countPost = 0;
  int countTotalFollowers = 0;
  int countTotalFollowing = 0;
  bool following = false;

  @override
  void initState() {
    super.initState();
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowing();
    checkIfAlreadyFollowing();
  }

  getAllProfilePosts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await postReference
        .document(widget.userProfileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      countPost = querySnapshot.documents.length;
      postList = querySnapshot.documents
          .map((documentSnapshot) => Post.fromDocument(documentSnapshot))
          .toList();
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  getAllFollowing() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(widget.userProfileId)
        .collection("userFollowing")
        .getDocuments();

    setState(() {
      countTotalFollowing = querySnapshot.documents.length;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .getDocuments();

    setState(() {
      countTotalFollowers = querySnapshot.documents.length;
    });
  }

  createProfileView() {
    return FutureBuilder(
      future: userReference.document(widget.userProfileId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Center(child: CupertinoActivityIndicator());
        }
        User users = User.fromDocument(dataSnapshot.data);
        return Stack(
          children: <Widget>[
            Container(
              transform: Matrix4.translationValues(0.0, -32.0, 0.0),
              child: Column(children: <Widget>[
                Container(
                  child: ClipPath(
                    clipper: PageCustomClipper(),
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      height: 480.0,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [firstColor, secondColor])),
                      child: Column(
                        children: <Widget>[
                          createProfileTopView(users),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                createProfileBottomView(),
              ]),
            ),
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : Container(width: 0.0, height: 0.0),
          ],
        );
      },
    );
  }

  createProfileTopView(User users) {
    return Container(
      padding: EdgeInsets.only(top: 32.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.only(left: 16.0),
                onPressed: () => Navigator.pop(context),
                icon: Icon(FontAwesomeIcons.arrowAltCircleLeft),
                color: Colors.white,
              ),
              Container(
                child: Text(
                  users.username,
                  style: solidButtonTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              currentOnlineUserId == widget.userProfileId
                  ? IconButton(
                      padding: EdgeInsets.only(right: 16.0),
                      onPressed: moveToSettingPage,
                      icon: Icon(Icons.settings),
                      color: Colors.white,
                    )
                  : Container(
                      height: 0.0,
                      width: 40.0,
                    ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Stack(children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: users.profilePic == null
                    ? RoundedNetworkImage(
                        imageSize: 200.0,
                        image: "",
                        strokeWidth: 6.0,
                      )
                    : RoundedNetworkImage(
                        imageSize: 200.0,
                        image: users.profilePic,
                        strokeWidth: 6.0,
                      ),
              ),
            ),
            currentOnlineUserId == widget.userProfileId
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(top: 156.0, left: 120.0),
                      child: RawMaterialButton(
                        padding: EdgeInsets.all(8.0),
                        shape: CircleBorder(),
                        fillColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                          size: 24.0,
                          color: secondColor,
                        ),
                        onPressed: () {
                          showUploadBottomSheet(context);
                        },
                      ),
                    ),
                  )
                : Container(
                    height: 0.0,
                    width: 48.0,
                  ),
          ]),
          SizedBox(
            height: 16.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              users.name,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              users.bio,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.80), fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Container(
            child: createButton(),
          )
        ],
      ),
    );
  }

  createProfileMidView() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setOrientation("list");
                },
                child: Counter(
                  number: countPost,
                  title: "Posts",
                ),
              ),
              InkWell(
                onTap: () {
                  moveToFollowersPage();
                },
                child: Counter(
                  number: countTotalFollowers,
                  title: "Followers",
                ),
              ),
              InkWell(
                onTap: () {
                  moveToFollowingPage();
                },
                child: Counter(
                  number: countTotalFollowing,
                  title: "Following",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createProfileBottomView() {
    return Column(
      children: <Widget>[
        createProfileMidView(),
        SizedBox(height: 16.0),
        Divider(
          color: Theme.of(context).primaryColorDark,
          height: 0.0,
        ),
        createListAndGridPost(),
        Divider(
          color: Theme.of(context).primaryColorDark,
          height: 0.0,
        ),
        SizedBox(height: 4.0),
        currentOnlineUserId == widget.userProfileId || following == true
            ? displayProfilePost()
            : Container(
                padding: EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text(
                    "Account is Private!\n Follow this User to view posts.",
                    style: TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonAndFunction(
          title: "Edit Profile", performFunction: editUserProfile);
    } else if (following) {
      return createButtonAndFunction(
          title: "Unfollow", performFunction: unFollowUser);
    } else if (!following) {
      return createButtonAndFunction(
          title: "Follow", performFunction: followUser);
    }
  }

  unFollowUser() {
    setState(() {
      following = false;
    });

    followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    followingReference
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    activityFeedReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  followUser() {
    setState(() {
      following = true;
    });

    followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .setData({});

    followingReference
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .setData({});

    activityFeedReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "username": currentUser.username,
      "timestamp": DateTime.now(),
      "userProfilePic": currentUser.profilePic,
      "userId": currentOnlineUserId
    });
  }

  Container createButtonAndFunction({String title, Function performFunction}) {
    return Container(
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 180.0,
          height: 32.0,
          child: Text(
            title,
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EditUserProfilePage(
                  currentOnlineUserId: currentOnlineUserId,
                )));
  }

  showUploadBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    moveToUploadProfilePicturePage();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.camera_enhance,
                          color: Theme.of(context).accentColor,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          "Select Profile Picture",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                CompleteSignup()));
                    print("View Profile Picture Pressed");
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.picture_in_picture_alt,
                          color: Theme.of(context).accentColor,
                          size: 32.0,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        Text(
                          "View Profile Picture",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    print("Edit Profile Picture Pressed");
                  },
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
                          "Edit Profile Picture",
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
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            createProfileView(),
          ],
        ),
      ),
    );
  }

  displayProfilePost() {
    if (isLoading) {
      return Center(child: CupertinoActivityIndicator());
    } else if (postList.isEmpty) {
      return Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                top: 32.0, left: 32.0, right: 32.0, bottom: 8.0),
            child: Icon(
              Icons.photo_library,
              color: Colors.grey,
              size: 240.0,
            ),
          ),
          Text(
            "No Posts",
            style: TextStyle(
                color: firstColor, fontSize: 40.0, fontWeight: FontWeight.bold),
          )
        ],
      ));
    } else if (postOrientation == "grid") {
      List<GridTile> gridTileList = [];
      postList.forEach((eachPost) {
        gridTileList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTileList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postList,
      );
    }
  }

  createListAndGridPost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? secondColor : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? secondColor : Colors.grey,
        )
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  moveToUploadProfilePicturePage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UploadProfilePicturePage()));
  }

  moveToFollowingPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => FollowingPage()));
  }

  moveToFollowersPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => FollowersPage()));
  }

  moveToSettingPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => SettingsPage()));
  }
}

class PageCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80.0);
    path.quadraticBezierTo(
        size.width / 2, size.height + 80.0, size.width, size.height - 80.0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
