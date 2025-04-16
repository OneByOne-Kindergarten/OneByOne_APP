import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:one_by_one/common/app_colors.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();

    /// 네이티브 스플래시 제거
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.blue3Color,
        child: Stack(
          children: [

            // 이미지
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.4,
                child: Image.asset(
                  'assets/image/splash_main_with_name.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
