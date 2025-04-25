import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:one_by_one/common/ad_helper.dart';
import 'package:one_by_one/controller/webview_controller.dart';

/// 배너 광고 위젯
class BottomBannerAdWidget extends StatefulWidget {
  const BottomBannerAdWidget({super.key});

  @override
  State<BottomBannerAdWidget> createState() => _BottomBannerAdWidgetState();
}

class _BottomBannerAdWidgetState extends State<BottomBannerAdWidget> {
  /// 배너 광고
  BannerAd? _bannerAd;

  /// 배너 광고 로드 여부
  bool _isAdLoaded = false;

  /// 웹뷰 컨트롤러
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // 웹뷰 컨트롤러 가져오기
    _webViewController = Get.find<WebViewController>();
    _loadBannerAd();
  }

  /// 배너 광고 로드
  void _loadBannerAd() {
    _bannerAd = AdHelper.createBannerAd()
      ..load().then((value) {
        setState(() {
          _isAdLoaded = true;
        });
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      
      final adHeight = (_isAdLoaded && _bannerAd != null)
          ? _bannerAd!.size.height.toDouble()
          : 50.0;

      // 광고 표시 여부에 따라 실제 광고 또는 빈 컨테이너 반환
      return Container(
        width: double.infinity,
        height: adHeight,
        color: Colors.transparent,
        child: (_isAdLoaded && _bannerAd != null && _webViewController.showBottomBanner.value)
            ? AdWidget(ad: _bannerAd!)
            : const SizedBox.shrink(),
      );
    });
  }
}
