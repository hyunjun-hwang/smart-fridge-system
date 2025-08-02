import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchFoodInfo(String foodName) async {
  const String apiKey = 'aC9p2FWLKdtxRQI%2FqYrTTCIl9LwAHXOl1ZJ3hcon7nFhVsWWxCck2f03W%2BMCrNj1b8F3wJSUzouE7pYGqHKRfQ%3D%3D';
  final String encodedFoodName = Uri.encodeComponent(foodName);
  final String url = 'https://openapi.foodsafetykorea.go.kr/api/$apiKey/json/1/5?desc_kor=$encodedFoodName';

  print('📡 요청 URL: $url');

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final body = data['body'];
      final items = body?['items'];

      if (items != null) {
        for (var item in items) {
          print('🍽️ 음식명: ${item['food_Nm']}');
          print(' - 식품코드: ${item['food_Code']}');
          print(' - 식품군: ${item['food_Grupp']}');
          print(' - 연도: ${item['examin_Year']}');
        }
      } else {
        print('⚠️ 결과 없음');
      }
    } else {
      print('❌ 응답 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('에러 발생: $e');
  }
}
