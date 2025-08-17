import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  // [개선] 로딩 상태와 데이터 필드 분리
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _name = '사용자';
  int? _height;
  int? _weight;
  String? _dob; // [개선] age 대신 생년월일(dob) 사용
  String? _gender;
  String _email = '';
  String? _profileImagePath; // [추가] 프로필 이미지 경로

  // [삭제] 🚨 보안상 매우 위험하므로 Provider에서 비밀번호를 제거합니다.
  // String _password = '12345678';

  String get name => _name;
  int? get height => _height;
  int? get weight => _weight;
  String? get dob => _dob;
  String? get gender => _gender;
  String get email => _email;
  String? get profileImagePath => _profileImagePath;

  UserProvider() {
    loadUserData(); // Provider 생성 시 사용자 데이터 로드
  }

  // [추가] Firestore에서 사용자 데이터를 불러오는 함수
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['id'] ?? '사용자';
        _email = data['email'] ?? '';
        _height = data['height'];
        _weight = data['weight'];
        _dob = data['dob'];
        _gender = data['gender'];
        _profileImagePath = data['profileImagePath'];
      }
    } catch (e) {
      debugPrint("UserProvider 데이터 로딩 에러: $e");
      // 에러 처리 (예: 기본값 설정)
    }

    _isLoading = false;
    notifyListeners();
  }

  // [개선] 필요한 필드만 선택적으로 업데이트 하도록 변경
  void updateUser({
    String? newName,
    int? newHeight,
    int? newWeight,
    String? newDob,
    String? newGender,
    String? newEmail,
    String? newImagePath,
  }) {
    if (newName != null) _name = newName;
    if (newHeight != null) _height = newHeight;
    if (newWeight != null) _weight = newWeight;
    if (newDob != null) _dob = newDob;
    if (newGender != null) _gender = newGender;
    if (newEmail != null) _email = newEmail;
    if (newImagePath != null) _profileImagePath = newImagePath;

    notifyListeners();
  }
}