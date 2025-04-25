import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_by_one/common/ad_helper.dart';
import 'package:one_by_one/common/common_util.dart';
import 'package:one_by_one/common/pref/app_pref.dart';

import '../common/app_page_url.dart';

/// 웹큐 Getx Controller
class WebViewController extends GetxController {

  static WebViewController get to => Get.find();

  /// 딥링크 스트림
  StreamSubscription? _sub;

  /// 전면 광고
  InterstitialAd? _interstitialAd;

  /// WebView Key
  final GlobalKey webViewKey = GlobalKey();

  final appLinks = AppLinks();

  /// WebView Controller - 웹뷰 상태 컨트롤러
  late final InAppWebViewController webViewController;

  /// WebView URL - RxString
  final RxString myUrl = "$baseUrl/".obs;

  /// 웹뷰 초기 로드 완료 여부
  final RxBool isInitialLoadComplete = false.obs;
  
  /// 하단 배너 표시 여부
  final RxBool showBottomBanner = true.obs;
  
  /// 하단 배너 숨기기
  void hideBottomBanner() {
    showBottomBanner.value = false;
  }
  
  /// 하단 배너 표시
  void displayBottomBanner() {
    showBottomBanner.value = true;
  }

  @override
  void onInit() {

    /// 웹뷰 디버깅 로그 관리
    PlatformInAppWebViewController.debugLoggingSettings.excludeFilter.addAll(
        [
          RegExp("onLoadResource"),
          RegExp("onContentSizeChanged"),
        ]
    );

    /// 전면 광고 초기화
    _initInterstitialAd();

    /// 마지막 실행 시간 저장
    AdHelper.updateLastAppRunTime();

    /// 앱이 켜있는 동안의 딥링크 처리
    _handleIncomingLinks();

    /// 뒤로가기 버튼 인터셉터 등록
    BackButtonInterceptor.add(_backButtonInterceptor);

    super.onInit();
  }

  @override
  void onClose() {
    /// 뒤로가기 버튼 인터셉터 해제
    BackButtonInterceptor.remove(_backButtonInterceptor);

    /// 딥링크 스트림 구독 해제
    _sub?.cancel();

    super.onClose();
  }

  /// 뒤로가기 버튼 인터셉터
  Future<bool> _backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) async {
    await handleSimpleBackPress();
    return true;
  }

  /// 뒤로가기 메서드
  Future<void> handleSimpleBackPress() async {
    final canGoBack = await webViewController.canGoBack();
    if (canGoBack) {
      await webViewController.goBack();
    }
  }

  /// 전면 광고 초기화
  void _initInterstitialAd() async {
    if (AdHelper.shouldShowInterstitialAd()) {
      CommonUtil.logger.d("전면 광고 표시 조건 충족 >> ${Prefs.lastAppRunTime.get().isEmpty ? "첫 실행" : "2시간 이상 경과"}");
    _interstitialAd = await AdHelper.loadInterstitialAd();

    /// 전면광고 노출
    if (_interstitialAd != null) {
      CommonUtil.logger.d(" 전면 광고 로드 성공");
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          CommonUtil.logger.e("전면 광고 표시 실패 >> $error");
          ad.dispose();
        },
      );

      Future.delayed(const Duration(seconds: 2), () {
        CommonUtil.logger.d("전면 광고 표시!!");
        _interstitialAd?.show();
      });

    }
    } else {
      CommonUtil.logger.d("전면 광고 표시 조건 미충족 >> 2시간 미만 경과");
    }
  }

  /// 웹뷰 URL 변경 메서드
  void changeMyUrl(Uri newUrl) {
    myUrl.value = newUrl.toString();
  }

  /// 백그라운드 딥링크 처리 - 앱이 켜져있을 때
  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = appLinks.uriLinkStream.listen((Uri? uri) {
        if(uri == null) {
          return;
        }else{
          /// TODO : 딥링크 이동 처리
          return;
        }
      }, onError: (Object err) {
        debugPrint('딥링크 에러 => $err');
      });
    }
  }

  /// 앱 시작 초기 딥링크 처리 - 이후 페이지 이동
  Future<void> handleInitialUri() async {
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      /// TODO : 딥링크 이동 처리
      return;
    }
  }

  /// 초기 로드 완료 설정
  void setInitialLoadComplete() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    isInitialLoadComplete.value = true;
  }
}