import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// BaseUrl
/// TODO : BaseUrl 변경 필요
const baseUrl = "https://moyeobang.vercel.app";

class PageUrl {

  /// 메인 - RequestUrl
  static final mainRequestUrl = URLRequest(url: WebUri("$baseUrl/"));

}