import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:one_by_one/common/app_colors.dart';
import 'package:one_by_one/controller/webview_controller.dart';
import 'package:one_by_one/screen/custom_splash_screen.dart';
import 'package:one_by_one/widget/bottom_banner_ad_widget.dart';
import 'package:one_by_one/widget/webview_widget.dart';

/// 웹뷰 화면
class WebViewScreen extends GetView<WebViewController> {
  const WebViewScreen(this.initUrl, {super.key});

  /// 초기 URL
  final URLRequest initUrl;

  @override
  Widget build(BuildContext context) {
    /// getXController => 웹뷰 컨트롤러 주입
    Get.put(WebViewController(), permanent: true);

    /// 웹뷰 스크린
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [

            /// 웹뷰 스크린
            SafeArea(
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) async {
                  final shouldExit = await controller.handleBackPress(context);
                  if (shouldExit) {
                    SystemNavigator.pop();
                  }
                },
                child: Column(
                  children: <Widget>[

                    /// 웹뷰
                    Expanded(child: WebViewWidget(initUrl: initUrl)),

                    /// 하단 배너 광고
                    const BottomBannerAdWidget(),
                  ],
                ),
              ),
            ),

            /// 스플래시 이미지
            Obx(() => controller.isInitialLoadComplete.value
                ? const SizedBox.shrink()
                : const CustomSplashScreen()),
          ],
        ));
  }
}
