import 'app_preferences.dart';

/// 앱 정보 설정 - Rx
class PreferenceItem<T> {

  // 데이터
  final T defaultValue;

  // 키
  final String key;

  // 생성자
  PreferenceItem(this.key, this.defaultValue);


  // 저장 메서드
  void call(T value) {
    AppPreferences.setValue<T>(this, value);
  }

  // 저장 후 리턴 메서드
  Future<bool> set(T value) {
    return AppPreferences.setValue<T>(this, value);
  }

  // 호출 메서드
  T get() {
    return AppPreferences.getValue<T>(this);
  }

  // 삭제 메서드
  Future<bool> delete() {
    return AppPreferences.deleteValue<T>(this);
  }
}