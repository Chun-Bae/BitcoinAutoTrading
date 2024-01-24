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
    // API에 필요한 쿼리 파라미터를 여기에 추가합니다.
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
    // 필요하다면 여기에 추가 헤더를 추가합니다.
  };

  // API 요청 URL을 여기에 입력합니다.
  const url = 'https://api.upbit.com/v1/market/all';

  try {
    var response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      print('Data: ${response.body}');
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}
