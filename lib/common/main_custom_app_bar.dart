import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photonix_app/common/rounded_network_image.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/pages/profile_page.dart';
import 'package:photonix_app/pages/search_user_page.dart';

class MainCustomAppBar extends StatefulWidget {
  @override
  _MainCustomAppBarState createState() => _MainCustomAppBarState();
}

class _MainCustomAppBarState extends State<MainCustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      margin: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SearchUserPage()));
            },
            child: Icon(
              FontAwesomeIcons.search,
              color: Theme.of(context).accentColor,
            ),
          ),
          Text(
            "PHOTONIX",
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ProfilePage(
                            userProfileId: currentUser.uid,
                          )));
            },
            child: currentUser.profilePic == null
                ? RoundedNetworkImage(
                    imageSize: 32.0,
                    image: "",
                    strokeWidth: 0.0,
                  )
                : RoundedNetworkImage(
                    imageSize: 32.0,
                    image: currentUser.profilePic,
                    strokeWidth: 0.0,
                  ),
          )
        ],
      ),
    )));
  }
}
