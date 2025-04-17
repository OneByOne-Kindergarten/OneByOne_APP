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

      /// 웹뷰 공통 설정
      /// TODO : 웹뷰 설정 관리 분리
      initialSettings: InAppWebViewSettings(
        /// IOS 유투브 전체화면 방지
        isElementFullscreenEnabled: Platform.isAndroid ? true : false,

        /// 줌인 + 줌아웃 + 줌 컨트롤러 표시 - 방지
        supportZoom: false,
        builtInZoomControls: false,
        displayZoomControls: false,

        /// 자바스크립트 허용
        javaScriptCanOpenWindowsAutomatically: true,
        javaScriptEnabled: true,

        /// 다운로드 허용
        useOnDownloadStart: true,
        useOnLoadResource: true,
        useShouldOverrideUrlLoading: true,

        /// 백그라운드 재생 허용
        mediaPlaybackRequiresUserGesture: true,

        /// 파일 접근 cors 허용 + 접근 허용
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        allowContentAccess: true,

        /// 스크롤 허용
        verticalScrollBarEnabled: true,

        /// 오버 스크롤 방지
        overScrollMode: OverScrollMode.NEVER,
        disallowOverScroll: false,

        /// 기타 설정
        useHybridComposition: true,
        thirdPartyCookiesEnabled: true,
        allowFileAccess: true,
        supportMultipleWindows: true,
        limitsNavigationsToAppBoundDomains: true,
        allowsInlineMediaPlayback: true,
        allowsBackForwardNavigationGestures: true,

        /// IOS 빌드간 설정 확인
        isInspectable: true,
      ),

      /// 유저 스크립트 설정
      initialUserScripts: UnmodifiableListView<UserScript>([
        /// TODO : 스크립트 주입 여부 확인
      ]),

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

        /// 웹뷰에서 보내는 메시지 처리 핸들러
        controller.addJavaScriptHandler(
            handlerName: 'onWebViewMessage',
            callback: (args) async {
              if (args.isNotEmpty) {
                try {
                  final String messageString = args[0];
                  final Map<String, dynamic> message = jsonDecode(messageString);
                  final String messageType = message['type'];
                  final dynamic messageData = message['data'];
                  CommonUtil.logger.d('웹에서 받은 메시지: ${message['type']} | ${message['data']}');

                  /// 메시지 타입에 따른 처리
                  switch (messageType) {

                    case 'WEB_READY':
                      CommonUtil.logger.d('웹뷰 준비됨 >> $messageData');
                      break;


                    case 'REQUEST_FCM_TOKEN':
                      CommonUtil.logger.d('FCM 토큰 요청 >> $messageData');
                      try {
                        String fcmToken = Prefs.fcmToken.get();
                        return {'status': 'success', 'token': fcmToken};
                      } catch (e) {
                        CommonUtil.logger.e('FCM 토큰 요청 오류: $e');
                        return {'status': 'error', 'message': e.toString()};
                      }

                    case 'REQUEST_PERMISSION':
                      CommonUtil.logger.d('권한 요청 >> $messageData');
                      final String permissionType = messageData['type'];
                      switch (permissionType) {

                        case 'LOCATION':
                          final status = await Permission.location.request();
                          final isGranted = status.isGranted;
                          return {
                            'status': isGranted ? 'success' : 'error',
                            'message': isGranted
                                ? 'Permission granted'
                                : 'Location permission denied'
                          };

                        case 'STORAGE':
                          final status = await Permission.storage.request();
                          final isGranted = status.isGranted;
                          return {
                            'status': isGranted ? 'success' : 'error',
                            'message': isGranted
                                ? 'Permission granted'
                                : 'Storage permission denied'
                          };

                        case 'NOTIFICATION':
                          final status =
                              await Permission.notification.request();
                          final isGranted = status.isGranted;
                          return {
                            'status': isGranted ? 'success' : 'error',
                            'message': isGranted
                                ? 'Permission granted'
                                : 'Notification permission denied'
                          };

                        default:
                          return {
                            'status': 'error',
                            'message': '알 수 없는 권한 타입: $permissionType'
                          };
                      }
                  }
                  return {'status': 'success', 'received': true};
                } catch (e) {
                  debugPrint('메시지 처리 오류: $e');
                  return {'status': 'error', 'message': e.toString()};
                }
              }
              return {'status': 'error', 'message': 'Invalid message'};
            });
      },

      /// 콘솔 메시지 받기
      onConsoleMessage: (controller, consoleMessage) async {
      },

      /// SSL 인증서
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        return ServerTrustAuthResponse( action: ServerTrustAuthResponseAction.PROCEED);
      },

      /// 새 창 띄우기
      onCreateWindow: (controller, createWindowRequest) async {
        Uri? uri = createWindowRequest.request.url;
        if(uri != null){
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
