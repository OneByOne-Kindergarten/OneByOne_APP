import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 앱 실행 시 초기화 - 알림 설정
void initializeNotification() async {

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Android 알림 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
    'high_importance_channel',
    'high_importance_notification',
    importance: Importance.max,
  ));

  /// IOS 알림 채널 생성
  DarwinInitializationSettings iosInitializationSettings =
  const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );


  /// 초기화 설정
  InitializationSettings initializationSettings = InitializationSettings(
    android: const AndroidInitializationSettings("@mipmap/ic_launcher"),
    iOS: iosInitializationSettings,
  );

  /// 초기화 설정 적용
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // onDidReceiveBackgroundNotificationResponse: backgroundHandler
  );

  /// 포그라운드 상태 알림 설정
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: true,
    sound: true,
  );

  /// 알림 권한 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

}
