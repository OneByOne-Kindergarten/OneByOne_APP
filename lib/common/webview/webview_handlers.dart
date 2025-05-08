import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:one_by_one/common/common_util.dart';
import 'package:one_by_one/common/pref/app_pref.dart';

/// 웹뷰 자바스크립트 핸들러를 관리하는 클래스
class WebViewHandlers {

  /// 웹뷰 핸들러 등록
  static void registerHandlers(
      InAppWebViewController controller, dynamic getXController) {

    /// 웹뷰에서 보내는 메시지 처리 핸들러
    controller.addJavaScriptHandler(
      handlerName: 'onWebViewMessage',
      callback: (args) async {
        if (args.isNotEmpty) {
          try {
            final String messageString = args[0];
            final Map<String, dynamic> message = jsonDecode(messageString);
            final String messageType = message['type'];
            final dynamic messageData = message['data'];

            CommonUtil.logger
                .d('웹에서 받은 메시지: ${message['type']} | ${message['data']}');

            /// 메시지 타입에 따른 처리
            switch (messageType) {
              case 'WEB_READY':
                CommonUtil.logger.d('웹뷰 준비됨 >> $messageData');
                break;

              case 'REQUEST_FCM_TOKEN':
                CommonUtil.logger.d('FCM 토큰 요청 >> $messageData');
                return await _handleFcmTokenRequest();

              case 'REQUEST_PERMISSION':
                CommonUtil.logger.d('권한 요청 >> $messageData');
                return await _handlePermissionRequest(messageData);

              case 'REQUEST_LAT_LONG':
                var locationStatus = await Permission.location.status;
                if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
                  locationStatus = await Permission.location.request();
                }
                if (locationStatus == PermissionStatus.granted) {
                  Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
                  return {'status': 'true' , 'lat' : position.latitude.toString() , 'long' : position.longitude.toString()};
                } else {
                  return {'status': 'false', 'lat' : '0', 'long': '0'};
                }

              default:
                return {'status': 'success', 'received': true};
            }
          } catch (e) {
            debugPrint('메시지 처리 오류: $e');
            return {'status': 'error', 'message': e.toString()};
          }
        }
        return {'status': 'error', 'message': 'Invalid message'};
      },
    );
  }

  /// FCM 토큰 요청 처리
  static Future<Map<String, dynamic>> _handleFcmTokenRequest() async {
    try {
      String fcmToken = Prefs.fcmToken.get();
      return {'status': 'success', 'token': fcmToken};
    } catch (e) {
      CommonUtil.logger.e('FCM 토큰 요청 오류: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// 권한 요청 처리
  static Future<Map<String, dynamic>> _handlePermissionRequest(
      dynamic messageData) async {
    final String permissionType = messageData['type'];
    switch (permissionType) {

      case 'LOCATION':
        final status = await Permission.location.request();
        final isGranted = status.isGranted;
        return {
          'status': isGranted ? 'success' : 'error',
          'message':
              isGranted ? 'Permission granted' : 'Location permission denied'
        };

      case 'STORAGE':
        final status = await Permission.storage.request();
        final isGranted = status.isGranted;
        return {
          'status': isGranted ? 'success' : 'error',
          'message':
              isGranted ? 'Permission granted' : 'Storage permission denied'
        };

      case 'NOTIFICATION':
        final status = await Permission.notification.request();
        final isGranted = status.isGranted;
        return {
          'status': isGranted ? 'success' : 'error',
          'message': isGranted
              ? 'Permission granted'
              : 'Notification permission denied'
        };

      default:
        return {'status': 'error', 'message': '알 수 없는 권한 타입: $permissionType'};
    }
  }
}
