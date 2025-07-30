import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _username = '홍길동';
  String _email = 'john@example.com';

  String get username => _username;
  String get email => _email;

  void updateProfile({required String username, required String email}) {
    _username = username;
    _email = email;
    notifyListeners();
  }
}
