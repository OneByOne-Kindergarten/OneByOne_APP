import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:one_by_one/common/common_util.dart';
import 'package:one_by_one/common/pref/app_pref.dart';
import 'package:one_by_one/controller/webview_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:one_by_one/common/webview/webview_settings.dart';
import 'package:one_by_one/common/webview/webview_handlers.dart';

/// 웹뷰 위젯
class WebViewWidget extends StatelessWidget {
  const WebViewWidget({super.key, required this.initUrl});

  /// 초기 URL
  final URLRequest initUrl;

  @override
  Widget build(BuildContext context) {

    /// getXController => 웹뷰 컨트롤러 주입
    final WebViewController getXController = Get.find();

    return InAppWebView(
      key: getXController.webViewKey,
      initialUrlRequest: initUrl,
      initialSettings: WebViewSettings.defaultSettings,

      /// 유저 스크립트 설정 - 스크립트 주입 여부 확인 필요
      initialUserScripts: UnmodifiableListView<UserScript>([]),

      /// HTTP 에러 핸들링
      onReceivedHttpError: (controller, request, errorResponse) {
        var isForMainFrame = request.isForMainFrame ?? false;
        if (!isForMainFrame) {
          return;
        }
      },

      /// 권한 사용 요청
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT);
      },


      /// 웹뷰 생성
      onWebViewCreated: (InAppWebViewController controller) {
        getXController.webViewController = controller;

        /// 앱 시작 초기 딥링크 처리
        /// TODO : 기능 확인 필요
        getXController.handleInitialUri();

        /// 웹뷰 핸들러 등록
        WebViewHandlers.registerHandlers(controller, getXController);
      },

      /// 콘솔 메시지 받기
      onConsoleMessage: (controller, consoleMessage) async {},

      /// SSL 인증서
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse( action: ServerTrustAuthResponseAction.PROCEED);
      },

      /// 새 창 띄우기
      onCreateWindow: (controller, createWindowRequest) async {
        Uri? uri = createWindowRequest.request.url;
        if (uri != null) {
          launchUrl(uri);
        }
        return true;
      },

      /// 네이티브 링크 연결 설정
      /// TODO : 이후 기능 대비 확장 필요
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        var uri = navigationAction.request.url;
        if (uri == null) return NavigationActionPolicy.CANCEL;

        if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
            .contains(uri.scheme)) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },

      /// 웹뷰 로드 완료 처리
      onLoadStop: (controller, url) {
        getXController.setInitialLoadComplete();
      },
    );
  }
}
