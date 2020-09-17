import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photonix_app/model/Users.dart';
import 'package:photonix_app/pages/home_page.dart';
import 'package:photonix_app/pages/profile_page.dart';

class SearchUserPage extends StatefulWidget {
  final User eachUser;

  const SearchUserPage({Key key, this.eachUser}) : super(key: key);

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage>
    with AutomaticKeepAliveClientMixin<SearchUserPage> {
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> searchResults;

  searchUser(String searchText) async {
    Future<QuerySnapshot> allUsers = userReference
        .where("username", isGreaterThanOrEqualTo: searchText)
        .getDocuments();
    setState(() {
      searchResults = allUsers;
    });
  }

  searchAppBar() {
    return Container(
      child: SafeArea(
        child: Container(
          child: Container(
            width: 300.0,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: searchTextEditingController,
                        decoration: InputDecoration(
                            hintText: "Search",
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).accentColor)),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              color: Theme.of(context).accentColor,
                              onPressed: clearSearchText,
                            )),
                        onChanged: searchUser,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  clearSearchText() {
    searchTextEditingController.clear();
  }

  Container displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 200.0,
            ),
            Text(
              "Search People",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  displaySearchUserScreen() {
    return FutureBuilder(
      future: searchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<UserResult> searchUserResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUserResult.add(userResult);
        });
        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 64.0), child: searchAppBar()),
      body: searchResults == null
          ? displayNoSearchResultScreen()
          : displaySearchUserScreen(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;

  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () =>
                  displayUserProfile(context, userProfileId: eachUser.uid),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(eachUser.profilePic),
                  backgroundColor: Colors.grey,
                ),
                title: Text(
                  eachUser.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(eachUser.username,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
              ),
            )
          ],
        ),
      ),
    );
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
