import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:url_launcher/url_launcher.dart';

/// 공유 타입
enum ShareType {
  community,
  kindergarten,
  review,
}

/// 공유할 데이터 모델
class ShareModel {

  ShareType shareType;
  String title;
  String url;
  String id;
  bool isWork = false; // 리뷰 공유 시 필요

  ShareModel({
    required this.shareType,
    required this.title,
    required this.url,
    required this.id,
    this.isWork = false,
  });
}

/// 카카오 공유하기
class KakaoShareManager {

  /// 카카오톡 공유하기
  void shareMyCode(ShareModel shareModel) async {
    try {
      print('카카오 공유 시작: ${shareModel.title}');
      
      // 카카오톡 설치 여부 확인 (공식 문서 방식)
      bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();
      print('카카오톡 설치 여부: $isKakaoTalkSharingAvailable');
      
      // 추가 디버깅: 직접 kakaotalk 스키마 확인
      Uri kakaoTalkScheme = Uri.parse('kakaotalk://');
      bool canLaunchKakaoTalk = await canLaunchUrl(kakaoTalkScheme);
      print('kakaotalk:// 스키마 실행 가능: $canLaunchKakaoTalk');
      
      // 탬플릿 생성
      var template = _getTemplateV2(shareModel);
      print('템플릿 생성 완료');
      
      // 설치 여부에 따른 로직 분기
      if (isKakaoTalkSharingAvailable) {
         print('카카오톡으로 공유 시도');
         Uri uri = await ShareClient.instance.shareDefault(template: template);
         print('공유 URI 생성: $uri');
         
         try {
            await ShareClient.instance.launchKakaoTalk(uri);
            print('카카오톡 실행 완료');
         } catch (e) {
           print('카카오톡 직접 실행 오류: $e');
         }
        
      } else {
        print('웹 공유로 대체');
        Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(template: template);
        print('웹 공유 URL: $shareUrl');
        await launchBrowserTab(shareUrl, popupOpen: false);
        print('브라우저 실행 완료');
      }
    } catch (e) {
      print('카카오 공유 실행 중 오류: $e');
      rethrow;
    }
  }

  /// 탬플릿 제작
  DefaultTemplate _getTemplateV2(ShareModel shareModel){

    String title = shareModel.title;
    String url = shareModel.url;
    FeedTemplate template;

    switch (shareModel.shareType) {

      case ShareType.community:
        /// 커뮤니티
        template = FeedTemplate(
            content: Content(
              title: title,
              description: "원바원에서 해당 커뮤니티 글을 확인해보세요!",
              imageUrl: Uri.parse("https://github.com/user-attachments/assets/a68364bb-e3f4-461c-aa8b-ecdc7cbe6384"),
              imageHeight: 600,
              imageWidth: 1000,
              link: Link(
                // 딥링크로 앱 실행
                mobileWebUrl: Uri.parse('onebyone://community?communityId=${shareModel.id}'),
                androidExecutionParams: {'communityId': shareModel.id},
                iosExecutionParams: {'communityId': shareModel.id},
              ),
            ),
            buttons: [
              Button(
                title: '앱으로보기',
                link: Link(
                  // 딥링크로 앱 직접 실행
                  mobileWebUrl: Uri.parse('onebyone://community?communityId=${shareModel.id}'),
                  androidExecutionParams: {'communityId': shareModel.id},
                  iosExecutionParams: {'communityId': shareModel.id},
                ),
              ),
            ]);
        break;

      case ShareType.kindergarten:
        /// 유치원
        template = FeedTemplate(
            content: Content(
              title: title,
              description: "원바원에서 해당 유치원 정보를 확인해보세요!",
              imageUrl: Uri.parse("https://github.com/user-attachments/assets/3f707b5a-430e-410e-8703-ae370060315f"),
              imageHeight: 600,
              imageWidth: 1000,
              link: Link(
                // 딥링크로 앱 실행
                mobileWebUrl: Uri.parse('onebyone://kindergarten?kindergartenId=${shareModel.id}'),
                androidExecutionParams: {'kindergartenId': shareModel.id},
                iosExecutionParams: {'kindergartenId': shareModel.id},
              ),
            ),
            buttons: [
              Button(
                title: '앱으로보기',
                link: Link(
                  // 딥링크로 앱 직접 실행
                  mobileWebUrl: Uri.parse('onebyone://kindergarten?kindergartenId=${shareModel.id}'),
                  androidExecutionParams: {'kindergartenId': shareModel.id},
                  iosExecutionParams: {'kindergartenId': shareModel.id},
                ),
              ),
            ]);
        break;

      case ShareType.review:
        /// 리뷰
        template = FeedTemplate(
            content: Content(
              title: title,
              description: "원바원에서 해당 유치원 리뷰를 확인해보세요!",
              imageUrl: shareModel.isWork
                  // 근무리뷰
                  ? Uri.parse(
                      "https://github.com/user-attachments/assets/2d99e19c-7e1a-4d8b-9748-182889d6d04c")
                  // 실습 리뷰
                  : Uri.parse(
                      "https://github.com/user-attachments/assets/c1940651-2018-40d9-9ded-f4e40f6851bc"),
              imageHeight: 600,
              imageWidth: 1000,
              link: Link(
                // 딥링크로 앱 실행 (kindergartenId + isWork 필요)
                mobileWebUrl: Uri.parse('onebyone://review?kindergartenId=${shareModel.id}&isWork=${shareModel.isWork}'),
                androidExecutionParams: {'kindergartenId': shareModel.id, 'isWork': shareModel.isWork.toString()},
                iosExecutionParams: {'kindergartenId': shareModel.id, 'isWork': shareModel.isWork.toString()},
              ),
            ),
            buttons: [
              Button(
                title: '앱으로보기',
                link: Link(
                  // 딥링크로 앱 직접 실행 (kindergartenId + isWork 필요)
                  mobileWebUrl: Uri.parse('onebyone://review?kindergartenId=${shareModel.id}&isWork=${shareModel.isWork}'),
                  androidExecutionParams: {'kindergartenId': shareModel.id, 'isWork': shareModel.isWork.toString()},
                  iosExecutionParams: {'kindergartenId': shareModel.id, 'isWork': shareModel.isWork.toString()},
                ),
              ),
            ]);
        break;
    }
    return template;

  }

}