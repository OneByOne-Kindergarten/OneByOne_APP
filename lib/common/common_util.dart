import 'package:logger/logger.dart';

/// 로깅 및 센트리 유틸
class CommonUtil {
  static Logger logger = Logger();

  /// 문자열이 발견되지 않으면 원래 문자열을 반환합니다.
  static String customReplaceAll(
      String original, String searchValue, String replacement) {
    int index = original.indexOf(searchValue);
    if (index == -1) {
      return original;
    }

    // 첫 번째 발견된 문자열을 제외하고 나머지 부분을 찾고 대체합니다.
    String modifiedString = original.substring(0, index + searchValue.length) +
        original
            .substring(index + searchValue.length)
            .replaceAll(searchValue, replacement);

    return modifiedString;
  }

  /// 에러 로그를 콘솔과 함께 파일 로그에 저장
  static Future<void> writeErrorAndFileLog(
      String className, String logMessage) async {
    logger.e('[$className] 메세지: $logMessage');

    // TODO : 센트리 전송
    // Sentry.captureException(Exception('$className: $logMessage'));
  }

}
