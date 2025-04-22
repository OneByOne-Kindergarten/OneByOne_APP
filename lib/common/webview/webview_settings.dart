import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 웹뷰 설정을 관리하는 클래스
class WebViewSettings {

  /// 웹뷰 기본 설정
  static InAppWebViewSettings get defaultSettings {
    return InAppWebViewSettings(

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
    );
  }
} 