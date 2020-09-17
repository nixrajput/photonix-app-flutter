import 'package:flutter/material.dart';
import 'package:photonix_app/common/page_custom_app_bar.dart';

class FollowingPage extends StatefulWidget {
  @override
  _FollowingPageState createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56.0),
          child: PageCustomAppBar(
            title: "Following",
          )),
    );
  }
}
