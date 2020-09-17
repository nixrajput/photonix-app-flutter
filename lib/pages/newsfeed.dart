import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/common/post_widget.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/home_page.dart';

class NewsFeedPage extends StatefulWidget {
  final User fCurrentUser;

  NewsFeedPage({this.fCurrentUser});

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  bool isLoading = false;
  List<Post> posts;
  List<String> followingList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveNewsFeed() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.fCurrentUser.uid)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();

    List<Post> allPosts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowing() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(currentUser.uid)
        .collection("userFollowing")
        .getDocuments();

    setState(() {
      followingList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveNewsFeed();
    retrieveFollowing();
  }

  createUserNewsFeed() {
    if (posts == null) {
      return Center(child: CupertinoActivityIndicator());
    } else {
      return ListView(children: posts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        child: createUserNewsFeed(),
        onRefresh: () => retrieveNewsFeed(),
      ),
    );
  }
}
