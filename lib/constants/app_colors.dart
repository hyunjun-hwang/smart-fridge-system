import 'package:flutter/material.dart';

class AppColors {
  // 이 클래스의 인스턴스 생성 방지
  AppColors._();

  // --- 주요 테마 색상 ---
  // 앱의 핵심 색상 (타이틀, 주요 텍스트 등)
  static const Color primary = Color(0xFF003508);
  // 앱의 포인트 색상 (버튼, 하단 네비게이션, 활성화된 테두리 등)
  static const Color accent = Color(0xFFC7D8A4);


  // --- 텍스트 및 보조 색상 ---
  // 강조되지 않는 보조 텍스트 색상
  static const Color textSecondary = Color(0xFF83A092);
  // 기타 포인트 색상
  static const Color skyBlue = Color(0xFFC4D5E7);

  // --- 유통기한 상태 표시 색상 ---
  // 위험 상태 (유통기한 임박/지남)
  static const Color statusDanger = Color(0xFFF36945);
  // 경고 상태 (유통기한 주의)
  static const Color statusWarning = Color(0xFFA7D44B);
  // 안전 상태 (유통기한 넉넉함)
  static const Color statusSafe = Color(0xFFFFD000);

  // --- 기본 색상 ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFF333333);
}