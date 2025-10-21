import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:one_by_one/common/image_util.dart';
import 'package:one_by_one/controller/webview_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:one_by_one/common/webview/webview_settings.dart';
import 'package:one_by_one/common/webview/webview_handlers.dart';

/// 웹뷰 위젯
class WebViewWidget extends StatelessWidget {
  const WebViewWidget({super.key, required this.initUrl});

  /// 인텐트 수정 메서드 채널
  static const methodChannel = MethodChannel('PARSE_INTENT');

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

      /// 이미지 롱프레스 핸들러 (안드로이드 전용)
      onLongPressHitTestResult: (controller, hitTestResult) async {
        // 안드로이드에서만 작동
        if (!Platform.isAndroid) return;
        
        if (hitTestResult.type == InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
            hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE) {
          
          final imageUrl = hitTestResult.extra;
          if (imageUrl == null || imageUrl.isEmpty) return;
          
          // 이미지 프리뷰와 액션 메뉴를 함께 표시
          showDialog(
            context: context,
            barrierColor: Colors.black87,
            builder: (BuildContext dialogContext) {
              return GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 이미지 프리뷰
                      Flexible(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () {}, // 이미지 탭 시 닫히지 않도록
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error, color: Colors.white, size: 50),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 액션 버튼들
                      GestureDetector(
                        onTap: () {}, // 버튼 영역 탭 시 닫히지 않도록
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.share, color: Colors.blue),
                                title: const Text(
                                  '공유하기',
                                  style: TextStyle(fontSize: 16),
                                ),
                                onTap: () async {
                                  Navigator.pop(dialogContext);
                                  await ImageUtil.shareImage(imageUrl, context);
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.add_photo_alternate, color: Colors.blue),
                                title: const Text(
                                  '사진 앨범에 추가',
                                  style: TextStyle(fontSize: 16),
                                ),
                                onTap: () async {
                                  Navigator.pop(dialogContext);
                                  await ImageUtil.saveImageToGallery(imageUrl, context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },

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
        var url = navigationAction.request.url;

        /// 딥링크 - IOS
        if (url != null &&!["https","http","intent"].contains(url.scheme) && Platform.isIOS) {
          debugPrint("URL SCHEMA1 >> ${url.scheme}");
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            return NavigationActionPolicy.CANCEL;
          }else {
            debugPrint("오픈 안됨 >> ${url.rawValue}");
            return NavigationActionPolicy.CANCEL;
          }

        /// 딥링크 - AOS (커스텀 스키마)
        } else if (url != null && !["https","http","intent"].contains(url.scheme) && Platform.isAndroid) {
          debugPrint("URL SCHEMA_ANDROID3 >> ${url.scheme}");
          await controller.stopLoading();
          
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            debugPrint("커스텀 스키마 오픈 안됨 >> ${url.rawValue}");
          }
          return NavigationActionPolicy.CANCEL;

        /// 딥링크 - AOS (intent 스키마)
        } else if(url != null && ["intent"].contains(url.scheme)){
          debugPrint("URL SCHEMA2 >> ${url.scheme}");
          await controller.stopLoading();
          try {
            // 안드로이드 인텐트 파싱
            final parsedIntent = await methodChannel.invokeMethod('getAppUrl', {'url': url.rawValue});

            // WebUri 사용하여 대문자 유지
            if (await canLaunchUrl(WebUri(parsedIntent, forceToStringRawValue: true))) {
              launchUrl(WebUri(parsedIntent, forceToStringRawValue: true), mode: LaunchMode.externalApplication);
            } else {
              final marketUrl = await methodChannel.invokeMethod('getMarketUrl', {'url': url.rawValue});
              launchUrl(WebUri(marketUrl, forceToStringRawValue: true), mode: LaunchMode.externalApplication);
            }
          } on PlatformException catch (e) {
            debugPrint('${e.message}');
          }
          return NavigationActionPolicy.CANCEL;
          /// 딥링크 - AOS + 인코딩 되어 있는 인텐트
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
