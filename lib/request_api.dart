import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> fetchWithJwt() async {
  await dotenv.load(fileName: ".env");
  final accessKey = dotenv.env['ACCESS_KEY']!;
  final secretKey = dotenv.env['SECRET_KEY']!;

  var query = {
    // API에 필요한 쿼리 입력
    'market': 'KRW-BTC'
  };

  var m = utf8.encode(Uri(queryParameters: query).query);
  var queryHash = sha512.convert(m).toString();

  var nonce = Uuid().v4();
  var jwt = JWT({
    'access_key': accessKey,
    'nonce': nonce,
    'query_hash': queryHash,
    'query_hash_alg': 'SHA512',
  });

  var jwtToken = jwt.sign(SecretKey(secretKey), algorithm: JWTAlgorithm.HS256);
  var authorizationToken = 'Bearer $jwtToken';

  var headers = {
    'Authorization': authorizationToken,
    // 추가 헤더
  };

  // API 요청 URL 입력
  const url = 'https://api.upbit.com/v1/market/all?isDetails=true';

  try {
    var response = await http.get(Uri.parse(url));
    String jsondata = response.body;
    // var response = await http.get(Uri.parse(url), headers: headers);
    List<dynamic> markets = jsonDecode(jsondata);

    // "KRW-"로 시작하는 마켓 코드만 필터링합니다.
    var krwMarkets =
        markets.where((market) => market['market'].startsWith('KRW-'));

    // 결과를 출력합니다.
    for (var market in krwMarkets) {
      print(
          'Market: ${market['market']}, Korean Name: ${market['korean_name']}, English Name: ${market['english_name']}');
    }
    // 필터링된 마켓 코드에서 'market' 필드만 추출하고, 결과를 쉼표로 구분된 문자열로 변환합니다.
    String marketString =
        krwMarkets.map((market) => market['market']).join(',');
    print(marketString);

    String url2 = 'https://api.upbit.com/v1/ticker?markets=$marketString';

    var response2 = await http.get(Uri.parse(url2));
    print(response2.body);

    List<dynamic> markets_per = jsonDecode(response2.body);

    // 각 마켓의 전일 종가 대비 현재가의 변화율을 계산
    double avg=0;
    double cnt=0;
    markets_per.forEach((market) {
      cnt += 1;
      double tradePrice = market['trade_price'];
      double prevClosingPrice = market['prev_closing_price'];
      double changePercent =
          ((tradePrice - prevClosingPrice) / prevClosingPrice) * 100;
      avg += changePercent;
      print("${market['market']}: ${changePercent.toStringAsFixed(2)}%");
    });
    avg = avg/cnt;
    print("전체 평균 등락률: ${avg.toStringAsFixed(7)}%");
    // if (response.statusCode == 200) {
    //   print('Data: ${response.body}');
    // } else {
    //   print('Failed to load data: ${response.statusCode}');
    // }
  } catch (e) {
    print('Error occurred: $e');
  }
}
