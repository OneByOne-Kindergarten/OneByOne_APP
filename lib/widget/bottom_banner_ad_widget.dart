import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:one_by_one/controller/webview_controller.dart';

/// 배너 광고 위젯
class BottomBannerAdWidget extends GetView<WebViewController> {
  const BottomBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final adHeight = (controller.isAdLoaded.value && controller.bannerAd.value != null && controller.showBottomBanner.value)
          ? controller.bannerAd.value!.size.height.toDouble()
          : 0.0;

      // 광고 표시 여부에 따라 실제 광고 또는 빈 컨테이너 반환
      return Container(
        width: double.infinity,
        height: adHeight,
        color: Colors.transparent,
        child: (controller.isAdLoaded.value && controller.bannerAd.value != null && controller.showBottomBanner.value)
            ? AdWidget(ad: controller.bannerAd.value!)
            : const SizedBox.shrink(),
      );
    });
  }
}
