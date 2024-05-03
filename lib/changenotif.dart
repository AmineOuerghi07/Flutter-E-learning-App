import 'package:flutter/foundation.dart';
import 'user_model.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(); // Default empty user

  User get user => _user;

  void updateUserData(User newUser) {
    _user = newUser;
    notifyListeners();
  }
}
