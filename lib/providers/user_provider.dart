import 'package:flutter/cupertino.dart';
import 'package:twich_clone/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(uid: "", username: "", email: "");

  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
