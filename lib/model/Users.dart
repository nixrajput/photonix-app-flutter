import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String profilePic;
  final String country;
  final String dob;
  final String sex;
  final String username;
  final String bio;

  User(
      {this.name,
      this.email,
      this.uid,
      this.profilePic,
      this.country,
      this.dob,
      this.sex,
      this.username,
      this.bio});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        uid: doc.documentID,
        name: doc['name'],
        email: doc['email'],
        profilePic: doc['profilePic'],
        country: doc['country'],
        dob: doc['dob'],
        sex: doc['sex'],
        username: doc['username'],
        bio: doc['bio']);
  }
}
