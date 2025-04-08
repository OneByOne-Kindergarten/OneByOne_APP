import 'package:get/get_rx/get_rx.dart';
import 'package:one_by_one/common/pref/preference_item.dart';

import 'app_preferences.dart';

/// 앱 정보 설정 - Rx
class RxPreferenceItem<T, R extends Rx<T>> extends PreferenceItem<T> {
  final R _rxValue;
  bool _isLoaded = false;

  RxPreferenceItem(super.key, super.defaultValue)
      : _rxValue = createRxValue<T, R>(defaultValue);

  // 불러오기 메서드 -> SharedPreference 데이터 호출 및 연동
  void _load() {
    _isLoaded = true;
    _rxValue.value = get();
  }

  // 외부 호출 메서드
  @override
  void call(T value) {
    _rxValue.value = value;
    super.call(value);
  }

  // SharedPreference 데이터 저장 메서드
  @override
  Future<bool> set(T value) {
    _rxValue.value = value;
    return super.set(value);
  }

  // 호출 메서드
  @override
  T get() {
    if (!_isLoaded) {
      _load();
    }
    final value = AppPreferences.getValue<T>(this);
    if (_rxValue.value != value) {
      _rxValue.value = value;
    }
    return _rxValue.value;
  }

  // 삭제 메서드
  @override
  Future<bool> delete() {
    return AppPreferences.deleteValue<T>(this);
  }

  // Rx 전역 관리 변수 생성 메서드
  static R createRxValue<T, R extends Rx<T>>(T defaultValue) {
    switch (T) {
      case int:
        return RxInt(defaultValue as int) as R;
      case double:
        return RxDouble(defaultValue as double) as R;
      case bool:
        return RxBool(defaultValue as bool) as R;
      case String:
        return RxString(defaultValue as String) as R;
      default:
        return Rx<T>(defaultValue) as R;
    }
  }
}
