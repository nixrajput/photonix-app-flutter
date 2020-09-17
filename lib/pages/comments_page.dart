import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/common/page_custom_app_bar.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  CommentsPage({this.postId, this.postOwnerId, this.postImageUrl});

  @override
  _CommentsPageState createState() => _CommentsPageState(
      postId: postId, postOwnerId: postOwnerId, postImageUrl: postImageUrl);
}

class _CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController commentTextController = TextEditingController();

  _CommentsPageState({this.postId, this.postOwnerId, this.postImageUrl});

  saveComment() {
    if (commentTextController.text.isNotEmpty) {
      commentsReference.document(postId).collection("userComments").add({
        "username": currentUser.username,
        "comment": commentTextController.text,
        "timestamp": DateTime.now(),
        "url": currentUser.profilePic,
        "userId": currentUser.uid
      });

      bool isNotPostOwner = postOwnerId != currentUser.uid;

      if (isNotPostOwner) {
        activityFeedReference
            .document(postOwnerId)
            .collection("feedItems")
            .add({
          "type": "comment",
          "commentData": commentTextController.text,
          "postId": postId,
          "userId": currentUser.uid,
          "username": currentUser.username,
          "userProfilePic": currentUser.profilePic,
          "url": postImageUrl,
          "timestamp": DateTime.now(),
        });
      }
    }
    commentTextController.clear();
  }

  retrieveComments() {
    return StreamBuilder(
      stream: commentsReference
          .document(postId)
          .collection("userComments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }
        List<Comment> comments = [];
        dataSnapshot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56.0),
          child: PageCustomAppBar(
            title: "Comments",
          )),
      body: Column(
        children: <Widget>[
          Expanded(
            child: retrieveComments(),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: currentUser.profilePic != null
                  ? CachedNetworkImageProvider(currentUser.profilePic)
                  : null,
              backgroundColor: Colors.grey,
            ),
            title: TextFormField(
              controller: commentTextController,
              decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(
                    fontSize: 14.0,
                  ),
                  border: InputBorder.none),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Text(
                "POST",
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.userName, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      url: documentSnapshot["url"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              userName + ":  " + comment,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            leading: CircleAvatar(
              backgroundImage:
                  url != null ? CachedNetworkImageProvider(url) : null,
              backgroundColor: Colors.grey,
            ),
            subtitle: Text(
              timeAgo.format(timestamp.toDate()),
            ),
            trailing: Icon(
              Icons.favorite_border,
              size: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
