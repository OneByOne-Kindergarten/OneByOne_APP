import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_by_one/common/ad_helper.dart';

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

  @override
  void initState() {
    super.initState();
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
    return (_isAdLoaded && _bannerAd != null)

        /// 배너 광고
        ? Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            width: double.infinity,
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )

        /// 광고 로드 이전
        : const SizedBox(width: double.infinity, height: 50);
  }
}
