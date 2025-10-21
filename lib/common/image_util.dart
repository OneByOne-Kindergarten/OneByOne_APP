import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:one_by_one/common/common_util.dart';

/// 이미지 처리 유틸리티
class ImageUtil {
  
  /// 이미지 공유하기
  static Future<void> shareImage(String imageUrl, BuildContext context) async {
    File? tempFile;
    try {
      CommonUtil.logger.d("이미지 공유 시작: $imageUrl");

      // 이미지 다운로드 (타임아웃 추가)
      final response = await http.get(Uri.parse(imageUrl)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('이미지 다운로드 시간 초과');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('이미지 다운로드 실패');
      }

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}.jpg';
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      // 공유
      final result = await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '이미지 공유',
      );

      CommonUtil.logger.d("이미지 공유 완료: ${result.status}");

    } catch (e) {
      CommonUtil.logger.e("이미지 공유 실패: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 공유에 실패했습니다')),
        );
      }
    } finally {
      // 임시 파일 삭제
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
          CommonUtil.logger.d("임시 파일 삭제 완료");
        } catch (e) {
          CommonUtil.logger.e("임시 파일 삭제 실패: $e");
        }
      }
    }
  }

  /// 이미지 갤러리에 저장하기
  static Future<void> saveImageToGallery(String imageUrl, BuildContext context) async {
    File? tempFile;
    try {
      CommonUtil.logger.d("이미지 저장 시작: $imageUrl");

      // 이미지 다운로드 (타임아웃 추가)
      final response = await http.get(Uri.parse(imageUrl)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('이미지 다운로드 시간 초과');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('이미지 다운로드 실패');
      }

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final fileName = 'save_${DateTime.now().millisecondsSinceEpoch}.jpg';
      tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.bodyBytes);

      // gal을 사용하여 갤러리에 저장 (자동 권한 처리)
      await Gal.putImage(tempFile.path);

      CommonUtil.logger.d("이미지 저장 성공");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 갤러리에 저장했습니다')),
        );
      }

    } on GalException catch (e) {
      CommonUtil.logger.e("이미지 저장 실패 (Gal): ${e.type}");
      if (context.mounted) {
        final message = e.type == GalExceptionType.accessDenied
            ? '저장소 권한이 필요합니다. 설정에서 권한을 허용해주세요.'
            : '이미지 저장에 실패했습니다';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      CommonUtil.logger.e("이미지 저장 실패: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 저장에 실패했습니다')),
        );
      }
    } finally {
      // 임시 파일 삭제
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
          CommonUtil.logger.d("임시 파일 삭제 완료");
        } catch (e) {
          CommonUtil.logger.e("임시 파일 삭제 실패: $e");
        }
      }
    }
  }
}
