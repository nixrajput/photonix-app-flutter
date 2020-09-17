import 'package:flutter/material.dart';
import 'package:photonix_app/common/post_widget.dart';
import 'package:photonix_app/pages/post_screen_page.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  displayFullPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PostScreenPage(postId: post.postId, userId: post.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        displayFullPost(context);
      },
      child: Image.network(post.url),
    );
  }
}
