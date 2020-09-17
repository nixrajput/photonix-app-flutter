import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/common/page_custom_app_bar.dart';
import 'package:photonix_app/common/post_widget.dart';

import 'home_page.dart';

class PostScreenPage extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreenPage({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56.0),
          child: PageCustomAppBar(
            title: "Post",
          )),
      body: FutureBuilder(
        future: postReference
            .document(userId)
            .collection("userPosts")
            .document(postId)
            .get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(child: CupertinoActivityIndicator());
          }
          Post post = Post.fromDocument(dataSnapshot.data);
          return Container(
            child: Center(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
