import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:one_by_one/common/app_page_url.dart';
import 'package:one_by_one/common/pref/app_pref.dart';
import 'package:one_by_one/screen/webview_screen.dart';
import 'package:one_by_one/theme/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 앱 기본 로직 처리 App Widget
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  final initUrl = PageUrl.mainRequestUrl;

  /// 앱 버전 확인 + 알림 여부 전역 저장, 푸시 알림 뱃지 삭제
  @override
  void initState() {

    /// 토큰 설정
    getMyDeviceToken();

    /// FCM 수신
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;

      /// 알림 도착
      if(notification != null){
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(

            /// 안드로이드 알림 설정
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
              priority: Priority.high,
            ),

            /// IOS 알림 설정
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });

    /// 버전 + 플랫폼 설정
    _setVersion();

    /// 푸시 알림 뱃지 삭제
    _deleteBadge();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    /// 스플래시 이미지 우선 로딩
    precacheImage(const AssetImage('assets/image/splash_main.png'), context);

    /// Getx 사용
    return GetMaterialApp(
      theme: appThemeData,
      home: WebViewScreen(initUrl),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 앱 버전 설정 메서드
Future<void> _setVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // 버전 설정
  await Prefs.appBundleVersionRx.set(packageInfo.version);

  // 플랫폼 설정
  if (Platform.isIOS) {
    await Prefs.operatingSystem.set("IOS");
  } else if (Platform.isAndroid) {
    await Prefs.operatingSystem.set("AOS");
  }

  debugPrint("앱 버전 : ${Prefs.appBundleVersionRx.get()}");
  debugPrint("현재 운영 체제 : ${Prefs.operatingSystem.get()}");
}


/// FCM 토큰 설정
void getMyDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await Prefs.fcmToken.set(token!);
    debugPrint("토큰 설정 완료 : ${Prefs.fcmToken.get()}");
}


/// 푸시 알림 뱃지 지우기
Future<void> _deleteBadge() async {
  await FlutterAppBadge.count(0);
  debugPrint("뱃지 삭제");
}

/// TODO : 배포 시 스토어 URL 적용
// Future<void> _checkAppVersion() async {
//   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   await AppVersionUpdate.checkForUpdates(
//     appleId: '0000000000',
//     playStoreId: packageInfo.packageName,
//     country: 'kr',
//   ).then((result) async {
//     if (result.canUpdate!) {
//       await Get.dialog(
//         AlertDialog(
//           title: const Text('원바원'),
//           content: Text(
//             '${result.storeVersion} 업데이트가 존재합니다.\n업데이트 취소를 누르시면 기능에\n제한이 있을 수 있습니다.',
//             softWrap: true,
//             overflow: TextOverflow.visible,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Get.back();
//               },
//               child: const Text('취소'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String storeUrl = getStoreUrlValue(
//                     packageInfo.packageName, packageInfo.appName);
//                 if (storeUrl == "") return;
//                 launchUrl(
//                   WebUri(storeUrl),
//                   mode: LaunchMode.externalApplication,
//                 );
//                 Get.back();
//               },
//               child: const Text('확인'),
//             ),
//           ],
//         ),
//       );
//     }
//   });
// }

/// TODO : 배포 시 스토어 URL 적용
// String getStoreUrlValue(String packageName, String appName) {
//   if (Platform.isAndroid) {
//     return "https://play.google.com/store/apps/details?id=$packageName";
//   } else if (Platform.isIOS) {
//     return "http://apps.apple.com/kr/app/$appName/id0000000000";
//   } else {
//     return "";
//   }
// }