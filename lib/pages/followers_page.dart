import 'package:flutter/material.dart';
import 'package:photonix_app/common/page_custom_app_bar.dart';

class FollowersPage extends StatefulWidget {
  @override
  _FollowersPageState createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56.0),
          child: PageCustomAppBar(
            title: "Followers",
          )),
    );
  }
}
