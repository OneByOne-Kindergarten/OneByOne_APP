import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_by_one/app.dart';
import 'package:one_by_one/common/app_notification.dart';
import 'package:one_by_one/common/pref/app_preferences.dart';
import 'package:one_by_one/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:one_by_one/service/ad_scheduler_service.dart';
import 'package:one_by_one/common/ad_helper.dart';

/// 백그라운드 메시지 수신 호출 콜백 함수 - 엔트리 포인트
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    return;
  }
}

/// 플러터 시작점
void main() async {
  /// 위젯 생성
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// 1차 스플래시 유지
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// .env 파일 로딩
  await dotenv.load(fileName: "lib/.env");

  /// Google Mobile Ads 초기화
  await MobileAds.instance.initialize();

  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: [
        "21bf83d0790478cd54944d5c3bc86c55",
      ]
    ),
  );

  /// 저장 공간 권한 요청 추가
  await Permission.storage.request();

  /// 파이어베이스 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// FCM 알림 설정
  initializeNotification();

  /// 앱 알림 설정 파일 로드
  await AppPreferences.init();

  /// 앱 시작 시간 저장
  AdHelper.saveAppStartTime();

  if (Platform.isAndroid) {
    // 디버그 모드 개발자 도구 사용 설정
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    // 서비스 워커 사용 설정
    var swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);
    if (swAvailable && swInterceptAvailable) {
      ServiceWorkerController serviceWorkerController =
          ServiceWorkerController.instance();
      await serviceWorkerController.setServiceWorkerClient(ServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          return null;
        },
      ));
    }
  }

  /// APP 실행
  runApp(const App());

  /// 광고 스케줄러 서비스 초기화 - App이 실행된 후 초기화
  await Get.putAsync(() => AdSchedulerService().init());
}
