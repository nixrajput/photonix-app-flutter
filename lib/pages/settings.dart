import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photonix_app/common/page_custom_app_bar.dart';
import 'package:photonix_app/model/Authentication.dart';

import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 64.0),
          child: PageCustomAppBar(
            title: "Settings",
          )),
      body: Container(
        margin: EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListViewItem(icon: FontAwesomeIcons.userAlt, text: "Account"),
            SizedBox(height: 16.0),
            ListViewItem(icon: FontAwesomeIcons.shieldAlt, text: "Privacy"),
            SizedBox(height: 16.0),
            ListViewItem(icon: FontAwesomeIcons.lock, text: "Security"),
            SizedBox(height: 16.0),
            ListViewItem(icon: FontAwesomeIcons.chartPie, text: "Data Usage"),
            SizedBox(height: 16.0),
            ListViewItem(
                icon: FontAwesomeIcons.solidBell, text: "Notifications"),
            SizedBox(height: 16.0),
            ListViewItem(
                icon: FontAwesomeIcons.handsHelping, text: "Help & Support"),
            SizedBox(height: 16.0),
            ListViewItem(icon: FontAwesomeIcons.share, text: "Invite Friends"),
            SizedBox(height: 16.0),
            ListViewItem(icon: FontAwesomeIcons.infoCircle, text: "About"),
            SizedBox(height: 16.0),
            InkWell(
                onTap: logOutUser,
                child: ListViewItem(
                    icon: FontAwesomeIcons.signOutAlt, text: "Logout")),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  sendToLoginPage() {
    Navigator.pop(context);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  logOutUser() async {
    try {
      await auth.signOutUser();
      Navigator.pop(context);
      sendToLoginPage();
    } catch (e) {
      print("Error = " + e.toString());
    }
  }
}

class ListViewItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ListViewItem({this.icon, this.text});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      padding: EdgeInsets.symmetric(horizontal: width / 4, vertical: 20.0),
      decoration: BoxDecoration(
          color: Color(0xFF4C4F5E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(32.0)),
      child: Row(
        children: <Widget>[
          Icon(icon),
          SizedBox(width: 32.0),
          Text(
            text,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
