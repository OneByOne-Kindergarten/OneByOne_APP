import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:one_by_one/common/pref/rx_preference_item.dart';


/// 앱 정보 설정
class Prefs {

  /*

  [구조]
  Getx -> Rx -> SharedPreference

  [기능]
  어플리케이션 전역에 필요한 지정 타입 Value 로컬에 저장하여 사용 가능

  [조건]
  main() 시점에 SharedPreference 인스턴스 생성 필요

   */

  /// 어플리케이션 알림 설정 여부
  static final isAdPushOnRx = RxPreferenceItem<bool, RxBool>('isAdPushOnRx', true);

  /// 어플리케이션 버전
  static final appBundleVersionRx = RxPreferenceItem<String, RxString>('appBundleRx', '');

  /// 어플리케이션 번들
  static final appBundleNameRx = RxPreferenceItem<String, RxString>('appBundleNameRx', '');

  /// 디바이스 FCM 토큰
  static final fcmToken = RxPreferenceItem<String, RxString>('fcmToken', '');

  /// 디바이스 운영체제 - IOS or AOS
  static final operatingSystem = RxPreferenceItem('operatingSystem', '');

  /// 전자사보 웹 버전
  static final saboWebVersionRx = RxPreferenceItem('saboWebVersionRx', '');

}