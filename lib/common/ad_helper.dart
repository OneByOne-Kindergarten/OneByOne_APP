import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_by_one/common/common_util.dart';
import 'package:one_by_one/common/pref/app_pref.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

/// AdMob 광고 관련 헬퍼 클래스
class AdHelper {

  /// 개발 환경 여부
  static bool isDev = false;

  /// 광고 활성화 여부
  static bool isAdEnabled = true;

  /// 테스트 광고 ID
  static const String testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String testInterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  
  /// 접이식 배너 테스트 광고 ID
  static const String testCollapsibleBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/2014213617';
  static const String testCollapsibleBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/8388050270';

  /// 배너 광고 ID
  static String get bannerAdUnitId {
    if (isDev) {
      final testId = Platform.isAndroid ? testBannerAdUnitIdAndroid : testBannerAdUnitIdIOS;
      print('🔹 테스트 광고 ID 사용: $testId');
      return testId;
    }
    
    if (Platform.isAndroid) {
      final realId = dotenv.env['ADMOB_BANNER_ID_ANDROID'] ?? testBannerAdUnitIdAndroid;
      print('🔸 실제 안드로이드 광고 ID 사용: $realId');
      return realId;
    } else if (Platform.isIOS) {
      final realId = dotenv.env['ADMOB_BANNER_ID_IOS'] ?? testBannerAdUnitIdIOS;
      print('🔸 실제 iOS 광고 ID 사용: $realId');
      return realId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  
  /// 접이식 배너 광고 ID
  static String get collapsibleBannerAdUnitId {
    if (isDev) {
      return Platform.isAndroid ? testCollapsibleBannerAdUnitIdAndroid : testCollapsibleBannerAdUnitIdIOS;
    }
    
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_COLLAPSIBLE_BANNER_ID_ANDROID'] ?? testCollapsibleBannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_COLLAPSIBLE_BANNER_ID_IOS'] ?? testCollapsibleBannerAdUnitIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 전면 광고 ID
  static String get interstitialAdUnitId {
    if (isDev) {
      return Platform.isAndroid ? testInterstitialAdUnitIdAndroid : testInterstitialAdUnitIdIOS;
    }
    
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_INTERSTITIAL_ID_ANDROID'] ?? testInterstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_INTERSTITIAL_ID_IOS'] ?? testInterstitialAdUnitIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// 앱 시작 시간 저장
  static void saveAppStartTime() {
    final now = DateTime.now().toIso8601String();
    Prefs.appStartTime.set(now);
  }

  /// iOS 14+ ATT (App Tracking Transparency) 권한 요청
  static Future<void> requestTrackingAuthorization() async {
    if (Platform.isIOS) {
      /// 권한 요청 전 상태 확인
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      CommonUtil.logger.d('현재 ATT 권한 상태: $status');
      
      /// 권한이 결정되지 않은 경우에만 요청
      if (status == TrackingStatus.notDetermined) {
        CommonUtil.logger.d('ATT 권한 요청 시작');
        final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
        CommonUtil.logger.d('ATT 권한 요청 결과: $newStatus');
      }
    }
  }

  /// 광고 표시 여부 확인
  static bool shouldShowInterstitialAd() {
    if (!isAdEnabled) return false;
    final String lastTimeStr = Prefs.lastAppRunTime.get();
    if (lastTimeStr.isEmpty) {
      /// 첫 실행에도 광고 노출
      return true;
    }

    final DateTime lastTime = DateTime.parse(lastTimeStr);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastTime);

    /// 2시간
    return difference.inHours >= 2;
  }
  
  /// 접이식 배너 광고 표시 여부 확인 (45분 주기)
  static bool shouldShowCollapsibleBannerAd() {
    if (!isAdEnabled) return false;
    final String lastTimeStr = Prefs.lastCollapsibleBannerAdTime.get();
    if (lastTimeStr.isEmpty) {
      /// 첫 실행에도 광고 노출
      return true;
    }

    final DateTime lastTime = DateTime.parse(lastTimeStr);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastTime);

    /// 45분
    return difference.inMinutes >= 45;
  }
  
  /// 현재 시간을 저장
  static void updateLastAppRunTime() {
    final now = DateTime.now().toIso8601String();
    Prefs.lastAppRunTime.set(now);
  }
  
  /// 접이식 배너 광고 표시 시간 저장
  static void updateLastCollapsibleBannerAdTime() {
    final now = DateTime.now().toIso8601String();
    Prefs.lastCollapsibleBannerAdTime.set(now);
  }
  
  /// 배너 광고 로드
  static BannerAd? createBannerAd() {
    if (!isAdEnabled) return null;
    try {
      return BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('배너광고 로드 성공 >> ${ad.adUnitId}');  
          },
          onAdFailedToLoad: (ad, error) {
            print('배너광고 로드 실패 >> 코드: ${error.code}, 메시지: ${error.message}');
            print('광고 도메인: ${error.domain}');
            ad.dispose();
          },
          onAdOpened: (ad) {
            print('배너광고 열림 >> ${ad.adUnitId}');
          },
          onAdClosed: (ad) {
            print('배너광고 닫힘 >> ${ad.adUnitId}');
          },
          onAdClicked: (ad) {
            print('배너광고 클릭됨 >> ${ad.adUnitId}');
          },
          onAdImpression: (ad) {
            print('배너광고 노출됨 >> ${ad.adUnitId}');
          },
        ),
      );
    } catch (e) {
      CommonUtil.logger.e('배너광고 생성 실패 >> $e');
      return null;
    }
  }
  
  /// 전면 광고 로드
  static Future<InterstitialAd?> loadInterstitialAd() async {
    if (!isAdEnabled) return null;

    InterstitialAd? interstitialAd;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('전면 광고 로드 성공 >> ${ad.adUnitId}');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) => print('광고 화면에 표시됨 >> ${ad.adUnitId}'),
            onAdDismissedFullScreenContent: (ad) {
              print('광고 닫힘 >> ${ad.adUnitId}');
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              CommonUtil.logger.e('광고 표시 실패 >> $error');
              ad.dispose();
            },
          );

          // 4초 지연 후 광고 표시
          Future.delayed(Duration(seconds: 4), () {
            print('광고 표시 시도 >> ${ad.adUnitId}');
            ad.show();
          });
        },
        onAdFailedToLoad: (error) {
          CommonUtil.logger.e('광고 로드 실패 >> $error');
        },
      ),
    );

    return interstitialAd;
  }
}