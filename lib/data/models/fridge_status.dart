// lib/data/models/fridge_status.dart (새 파일)

class FridgeSectionStatus {
  final double temperature;
  final double humidity;
  final String gasStatus;

  // 생성자
  FridgeSectionStatus({
    required this.temperature,
    required this.humidity,
    required this.gasStatus,
  });

  // Firestore에서 데이터를 받아올 때 사용할 팩토리 생성자 (편의 기능)
  factory FridgeSectionStatus.fromMap(Map<String, dynamic> map) {
    return FridgeSectionStatus(
      // num 타입으로 오기 때문에 toDouble()로 변환
      temperature: (map['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
      gasStatus: map['gasStatus'] as String? ?? '알 수 없음',
    );
  }
}