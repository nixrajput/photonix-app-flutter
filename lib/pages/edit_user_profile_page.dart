import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/common/page_custom_app_bar.dart';
import 'package:photonix_app/common/rounded_network_image.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/styles/colors.dart';

class EditUserProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  const EditUserProfilePage({Key key, this.currentOnlineUserId})
      : super(key: key);

  @override
  _EditUserProfilePageState createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _usernameEditingController = TextEditingController();
  TextEditingController _bioEditingController = TextEditingController();
  bool _isLoading = false;
  User users;

  bool _autoValidate = false;
  bool _isCheckingUsername = false;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot documentSnapshot =
        await userReference.document(widget.currentOnlineUserId).get();
    users = User.fromDocument(documentSnapshot);
    setState(() {
      _nameEditingController.text = users.name;
      _usernameEditingController.text = users.username;
      _bioEditingController.text = users.bio;
    });

    setState(() {
      _isLoading = false;
    });
  }

  String _validateName(String value) {
    if (_nameEditingController.text.isEmpty) {
      return "Name can't be empty!";
    }

    if (_nameEditingController.text.trim().length < 3) {
      return "Name is too short!";
    }

    return null;
  }

  String _validateUsername(String value) {
    if (_usernameEditingController.text.isEmpty) {
      return "Username can't be empty!";
    }

    if (_usernameEditingController.text.trim().length < 5) {
      return "Username is too short!";
    }

    return null;
  }

  String _validateBio(String value) {
    if (_bioEditingController.text.trim().length > 120) {
      return "Bio exceeded length!";
    }

    return null;
  }

  bool validateAndSave() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      return true;
    } else {
      _isLoading = false;
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  updateUserData() {
    setState(() {
      _isLoading = true;
    });

    if (validateAndSave()) {
      userReference.document(widget.currentOnlineUserId).updateData({
        "name": _nameEditingController.text,
        "bio": _bioEditingController.text,
        //"username": _usernameEditingController.text
      });
      setState(() {
        _isLoading = false;
      });
      SnackBar snackBar =
          SnackBar(content: Text("Profile updated successfully."));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  profilePictureView() {
    return Container(
        alignment: Alignment.center,
        child: RoundedNetworkImage(
          imageSize: 180.0,
          image: users.profilePic,
          strokeWidth: 0.0,
        ));
  }

  userInfoView() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: TextFormField(
              controller: _nameEditingController,
              validator: _validateName,
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondColor)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            child: TextFormField(
              controller: _usernameEditingController,
              autofocus: false,
              validator: _validateUsername,
              decoration: InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondColor)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            child: TextFormField(
              controller: _bioEditingController,
              validator: _validateBio,
              minLines: 1,
              maxLines: 10,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: "Bio",
                labelStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: secondColor)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
        ],
      ),
    );
  }

  buttonView() {
    double height = MediaQuery.of(context).size.height;
    return RaisedButton(
      padding: EdgeInsets.all(height / 50),
      color: secondColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      onPressed: updateUserData,
      child: Text(
        "UPDATE",
        style: TextStyle(color: Colors.white, fontSize: height / 45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 56.0),
            child: PageCustomAppBar(
              title: "Edit Profile",
            )),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: _isLoading == true
              ? Center(
                  child: CupertinoActivityIndicator(),
                )
              : Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      profilePictureView(),
                      userInfoView(),
                      _isCheckingUsername == true
                          ? Center(child: CupertinoActivityIndicator())
                          : Container(
                              width: 0.0,
                              height: 0.0,
                            ),
                      buttonView()
                    ],
                  ),
                ),
        ));
  }
}
