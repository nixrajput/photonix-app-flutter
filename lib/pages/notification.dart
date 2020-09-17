import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/pages/post_screen_page.dart';
import 'package:photonix_app/pages/profile_page.dart';
import 'package:timeago/timeago.dart' as tAgo;

class NotificationPage extends StatefulWidget {
  final User fCurrentUser;

  NotificationPage({this.fCurrentUser});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: FutureBuilder(
        future: retrieveNotifications(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
          return ListView(
            children: dataSnapshot.data,
          );
        },
      ),
    ));
  }

  retrieveNotifications() async {
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(currentUser.uid)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .getDocuments();

    List<NotificationItem> notifications = [];

    querySnapshot.documents.forEach((document) {
      notifications.add(NotificationItem.fromDocument(document));
    });

    return notifications;
  }
}

String notificationItemText;
Widget mediaPreview;

class NotificationItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfilePic;
  final String url;
  final Timestamp timestamp;

  NotificationItem(
      {this.username,
      this.type,
      this.commentData,
      this.postId,
      this.userId,
      this.userProfilePic,
      this.url,
      this.timestamp});

  factory NotificationItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationItem(
      username: documentSnapshot["username"],
      type: documentSnapshot["type"],
      commentData: documentSnapshot["commentData"],
      postId: documentSnapshot["postId"],
      userId: documentSnapshot["userId"],
      userProfilePic: documentSnapshot["userProfilePic"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Container(
      child: ListTile(
        title: GestureDetector(
          onTap: () => displayUserProfile(context, userProfileId: userId),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: [
              TextSpan(
                text: username,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: " $notificationItemText",
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
            ]),
          ),
        ),
        leading: GestureDetector(
          onTap: () => displayUserProfile(context, userProfileId: userId),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(userProfilePic),
          ),
        ),
        subtitle: Text(
          tAgo.format(timestamp.toDate()),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: mediaPreview,
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () =>
            displayPostScreen(context, postId: postId, userId: currentUser.uid),
        //displayOwnProfile(context, userProfileId: currentUser.uid),
        child: Container(
          width: 50.0,
          height: 50.0,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(url),
              )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      notificationItemText = "liked your post.";
    } else if (type == "comment") {
      notificationItemText = "replied: $commentData ";
    } else if (type == "follow") {
      notificationItemText = "started following you.";
    } else {
      notificationItemText = "Error, unknown type = $type";
    }
  }

  displayOwnProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }

  displayPostScreen(BuildContext context, {String postId, String userId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
                  postId: postId,
                  userId: userId,
                )));
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }
}
