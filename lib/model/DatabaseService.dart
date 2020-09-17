import 'package:photonix_app/pages/home_page.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  Future saveUserData(
      String uid, String name, String email, DateTime timestamp) async {
    return await userReference.document(uid).setData({
      'uid': uid,
      'name': name,
      'email': email,
      'timestamp': timestamp,
      'bio': ""
    });
  }

  Future completeSignupData(String dob, String sex, String country) async {
    return await userReference.document(uid).updateData({
      'dob': dob,
      'sex': sex,
      'country': country,
    });
  }
}
