import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. dotenv 임포트
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

/// 음식 이름을 기반으로 공공데이터포털에서 영양 정보 리스트를 비동기적으로 가져옵니다.
///
/// [foodName] 검색할 음식 이름.
/// 성공 시 `List<FoodItemn>`을 반환하고, 실패 시 예외를 발생시킵니다.
Future<List<FoodItemn>> fetchFoodInfoFromJson(String foodName) async {
  final String? serviceKey = dotenv.env['FOOD_API_SERVICE_KEY'];
  if (serviceKey == null) {
    throw Exception('.env 파일에 API 키가 설정되지 않았습니다.');
  }

  final queryParameters = {
    'serviceKey': serviceKey,
    'pageNo': '1',
    'numOfRows': '10',
    'type': 'json',
    'DESC_KOR': foodName, // Uri.https()는 자동 인코딩 처리하므로 별도 encodeComponent 필요 없음
  };

  final uri = Uri.https(
    'apis.data.go.kr',
    '/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntList',
    queryParameters,
  );

  try {
    final response = await http.get(uri);
    print('✅ 요청 URL: $uri');
    print('📦 상태코드: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
      final body = jsonBody['body'];
      if (body == null || body['items'] == null) {
        return [];
      }
      final List<dynamic> items = body['items'];
      return items.map<FoodItemn>((item) => FoodItemn.fromJson(item)).toList();
    } else {
      print('❌ 응답 본문: ${response.body}');
      throw Exception('API 응답 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ 예외 발생: $e');
    rethrow;
  }
}
