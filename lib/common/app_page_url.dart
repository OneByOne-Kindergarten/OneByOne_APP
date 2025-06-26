import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PageUrl {

  /// BaseUrl
  static final baseUrl = dotenv.env['BASE_URL'] ?? 'https://moyeobang.vercel.app';

  /// 메인 - RequestUrl
  static final mainRequestUrl = URLRequest(url: WebUri("$baseUrl/"));

}