import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = '홍길동';
  int _height = 183;
  int _weight = 75;
  int _age = 30;
  String _gender = '남성';
  String _email = '12345@naver.com';
  String _password = '12345678';

  String get name => _name;
  int get height => _height;
  int get weight => _weight;
  int get age => _age;
  String get gender => _gender;
  String get email => _email;
  String get password => _password;

  void updateProfile({
    required String name,
    required int height,
    required int weight,
    required int age,
    required String gender,
    required String email,
    required String password,
  }) {
    _name = name;
    _height = height;
    _weight = weight;
    _age = age;
    _gender = gender;
    _email = email;
    _password = password;
    notifyListeners();
  }
}
