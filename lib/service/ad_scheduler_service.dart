import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_by_one/common/ad_helper.dart';
import 'package:one_by_one/controller/webview_controller.dart';
import 'package:one_by_one/widget/collapsible_banner_ad_widget.dart';

/// 광고 스케줄러 서비스
class AdSchedulerService extends GetxService {
  
  /// 팝업 표시 여부
  final RxBool _isShowingAd = false.obs;
  
  /// 타이머
  Timer? _adTimer;
  
  /// 싱글톤 인스턴스
  static AdSchedulerService get to => Get.find<AdSchedulerService>();
  
  /// 초기화
  Future<AdSchedulerService> init() async {
    // 앱이 완전히 로드된 후 타이머 초기화를 위해 약간 지연
    Future.delayed(const Duration(seconds: 2), () {
      _initAdTimer();
    });
    return this;
  }
  
  /// 광고 타이머 초기화
  void _initAdTimer() {
    if (_adTimer != null) {
      _adTimer!.cancel();
    }
    
    // 1분마다 체크하여 45분이 지났는지 확인
    _adTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // 현재 광고가 표시 중이 아니고, 45분이 지났으면 광고 표시
      if (!_isShowingAd.value && AdHelper.shouldShowCollapsibleBannerAd()) {
        _showCollapsibleBannerAd();
      }
    });
    
    // 앱이 처음 실행되었을 때 조건 확인
    if (AdHelper.shouldShowCollapsibleBannerAd()) {
      // 10초 지연 후 광고 표시 (앱 시작 직후에는 표시하지 않도록)
      Future.delayed(const Duration(seconds: 15), () {
        if (Get.context != null && Get.overlayContext != null) {
          _showCollapsibleBannerAd();
        }
      });
    }
  }
  
  /// 접이식 배너 광고 표시
  void _showCollapsibleBannerAd() {
    if (_isShowingAd.value) return;
    
    // 오버레이 컨텍스트 확인
    final context = Get.overlayContext;
    if (context == null) {
      print('오버레이 컨텍스트가 없습니다.');
      return;
    }
    
    _isShowingAd.value = true;
    
    // 하단 배너는 더 이상 숨기지 않고 투명도만 조절함
    // 하단 배너 투명하게 처리 (공간은 유지)
    try {
      // 웹뷰 컨트롤러가 초기화되었는지 확인 후 하단 배너 숨기기
      if (Get.isRegistered<WebViewController>()) {
        WebViewController.to.hideBottomBanner();
      }
    } catch (e) {
      print('하단 배너 숨기기 실패: $e');
    }
    
    // 오버레이로 접이식 배너 광고 표시 (기존 배너 바로 위에 위치)
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final safeAreaBottom = mediaQuery.padding.bottom;
    
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: safeAreaBottom, // 안전 영역 고려
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 배너 닫기 버튼
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                    _isShowingAd.value = false;
                    // 닫은 경우에도 타이머 재설정
                    AdHelper.updateLastCollapsibleBannerAdTime();
                    
                    // 하단 배너 다시 표시
                    _showBottomBannerAgain();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              // 접이식 배너 광고
              const CollapsibleBannerAdWidget(),
            ],
          ),
        ),
      ),
    );
    
    // 현재 컨텍스트의 오버레이에 추가
    try {
      Overlay.of(context).insert(overlayEntry);
      
      // 광고 시간 업데이트
      AdHelper.updateLastCollapsibleBannerAdTime();
      
      // 30초 후 자동으로 광고 닫기
      Future.delayed(const Duration(seconds: 30), () {
        if (_isShowingAd.value) {
          overlayEntry?.remove();
          _isShowingAd.value = false;
          
          // 하단 배너 다시 표시
          _showBottomBannerAgain();
        }
      });
    } catch (e) {
      print('오버레이 추가 중 오류 발생: $e');
      _isShowingAd.value = false;
      
      // 오류 발생 시 하단 배너 다시 표시
      _showBottomBannerAgain();
    }
  }
  
  /// 하단 배너 다시 표시
  void _showBottomBannerAgain() {
    try {
      // 웹뷰 컨트롤러가 초기화되었는지 확인 후 하단 배너 다시 표시
      if (Get.isRegistered<WebViewController>()) {
        WebViewController.to.displayBottomBanner();
      }
    } catch (e) {
      print('하단 배너 표시 실패: $e');
    }
  }
  
  /// 서비스 종료
  @override
  void onClose() {
    _adTimer?.cancel();
    super.onClose();
  }
} 