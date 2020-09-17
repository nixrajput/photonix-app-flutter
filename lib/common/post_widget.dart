import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/comments_page.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/pages/profile_page.dart';
import 'package:photonix_app/styles/colors.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final Timestamp timestamp;
  final String username;
  final String description;
  final String location;
  final String url;
  final dynamic likes;

  Post(
      {this.postId,
      this.ownerId,
      this.timestamp,
      this.username,
      this.description,
      this.location,
      this.url,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
      likes: documentSnapshot["likes"],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      description: this.description,
      location: this.location,
      url: this.url,
      likes: this.likes,
      timestamp: this.timestamp,
      likeCount: getTotalNumberOfLikes(this.likes));
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String description;
  final String location;
  final String url;
  Map likes;
  final Timestamp timestamp;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.uid;
  int countTotalComments = 0;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.description,
      this.location,
      this.url,
      this.likes,
      this.likeCount,
      this.timestamp});

  @override
  void initState() {
    countAllComments();
    super.initState();
  }

  countAllComments() async {
    QuerySnapshot querySnapshot = await commentsReference
        .document(postId)
        .collection("userComments")
        .getDocuments();

    setState(() {
      countTotalComments = querySnapshot.documents.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Container(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostBody(),
          createPostFoot(),
        ],
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }

  createPostHead() {
    return FutureBuilder(
      future: userReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Center(child: CupertinoActivityIndicator());
        }
        User users = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnlineUserId == ownerId;

        return ListTile(
          leading: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: ownerId),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(users.profilePic),
              backgroundColor: Colors.grey,
            ),
          ),
          title: GestureDetector(
            onTap: () => displayUserProfile(context, userProfileId: ownerId),
            child: Text(
              users.username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            timeAgo.format(timestamp.toDate()),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.expand_more,
                  ),
                  onPressed: () => showOptionBottomSheet(context),
                )
              : Text(""),
        );
      },
    );
  }

  showOptionBottomSheet(context) {
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
                    Navigator.pop(context);
                    removeUserPost();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Center(
                      child: Text(
                        "Delete Post",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    print("Save Post Pressed");
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Center(
                      child: Text(
                        "Save Post",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    print("Edit Post Pressed");
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                    child: Center(
                      child: Text(
                        "Edit Post",
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold),
                      ),
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

  controlPostDelete(BuildContext mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Do you want to delete?",
              style: TextStyle(color: secondColor),
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Yes",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  removeUserPost();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "No",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  removeUserPost() async {
    postReference
        .document(ownerId)
        .collection("userPosts")
        .document(postId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    storageReference
        .child(currentOnlineUserId)
        .child("post$postId.jpg")
        .delete();

    QuerySnapshot querySnapshot = await activityFeedReference
        .document(ownerId)
        .collection("feedItems")
        .where("postId", isEqualTo: postId)
        .getDocuments();

    querySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });

    QuerySnapshot commentQuerySnapshot = await commentsReference
        .document(postId)
        .collection("userComments")
        .getDocuments();

    commentQuerySnapshot.documents.forEach((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  controlUserLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;

    if (_liked) {
      postReference
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({
        "likes.$currentOnlineUserId": false,
      });
      removeLike();
      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else if (!_liked) {
      postReference
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({
        "likes.$currentOnlineUserId": true,
      });
      addLike();

      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.uid,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfilePic": currentUser.profilePic
      });
    }
  }

  removeLike() {
    bool _isNotPostOwner = currentOnlineUserId != ownerId;

    if (_isNotPostOwner) {
      activityFeedReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  createPostBody() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20.0, bottom: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(description, style: TextStyle(fontSize: 18.0)),
              )
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
                onDoubleTap: controlUserLikePost, child: Image.network(url)),
            showHeart
                ? Image.asset(
                    'assets/icons/love.png',
                    width: 80.0,
                    height: 80.0,
                  )
                : Text(""),
          ],
        )
      ],
    );
  }

  createPostFoot() {
    return Container(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 56.0, left: 20.0),
                  ),
                  GestureDetector(
                    onTap: () => controlUserLikePost(),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: firstColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 64.0),
                  ),
                  GestureDetector(
                    onTap: () => displayComments(context,
                        postId: postId, ownerId: ownerId, url: url),
                    child: Icon(
                      Icons.chat_bubble_outline,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(
                      Icons.share,
                    ),
                  )
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.0),
                    child: Text(
                      "$likeCount likes",
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 28.0),
                    child: Text(
                      "$countTotalComments comments",
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(right: 20.0),
                child: Text(
                  location,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  displayComments(BuildContext context,
      {String postId, String ownerId, String url}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentsPage(
          postId: postId, postOwnerId: ownerId, postImageUrl: url);
    }));
  }
}
