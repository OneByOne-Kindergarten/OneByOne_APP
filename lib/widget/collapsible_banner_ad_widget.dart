import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_by_one/common/ad_helper.dart';

/// 접이식 배너 광고 위젯
class CollapsibleBannerAdWidget extends StatefulWidget {
  const CollapsibleBannerAdWidget({super.key});

  @override
  State<CollapsibleBannerAdWidget> createState() => _CollapsibleBannerAdWidgetState();
}

class _CollapsibleBannerAdWidgetState extends State<CollapsibleBannerAdWidget> {
  /// 배너 광고
  BannerAd? _bannerAd;

  /// 배너 광고 로드 여부
  bool _isLoaded = false;
  
  /// 광고 로딩 시작 여부
  bool _isAdLoading = false;
  
  /// 현재 화면 방향
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    // initState에서는 MediaQuery 사용 불가
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 준비되었을 때 광고 로드
    if (!_isAdLoading) {
      _isAdLoading = true;
      _loadAd();
    }
  }

  /// 접이식 배너 광고 로드
  void _loadAd() async {
    // 화면 크기 정보 가져오기
    final screenWidth = MediaQuery.of(context).size.width.truncate();
    
    // 안정적인 접이식 배너 크기를 위해 기본 크기에서 시작
    // LARGE_BANNER는 일반 배너보다 큰 크기 (320x100)
    // MEDIUM_RECTANGLE은 더 큰 사각형 배너 (300x250)
    const adSize = AdSize.mediumRectangle; // 300x250 크기의 더 큰 배너
    
    // 접이식 요청 생성 - bottom 위치 지정
    const adRequest = AdRequest(extras: {
      "collapsible": "bottom",
    });

    BannerAd(
      adUnitId: AdHelper.collapsibleBannerAdUnitId,
      request: adRequest,
      size: adSize,
      listener: BannerAdListener(
        // 광고가 로드되었을 때 호출
        onAdLoaded: (ad) {
          print('접이식 배너 광고 로드 성공 - 크기: ${ad.responseInfo?.responseExtras}');
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        // 광고 로드 실패시 호출
        onAdFailedToLoad: (ad, err) {
          print('접이식 배너 광고 로드 실패: $err');
          ad.dispose();
        },
        // 광고가 열릴 때 호출
        onAdOpened: (ad) {
          print('접이식 배너 광고 열림');
        },
        // 광고가 닫힐 때 호출
        onAdClosed: (ad) {
          print('접이식 배너 광고 닫힘');
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation != orientation) {
          // 화면 방향이 바뀌면 광고 다시 로드
          _isLoaded = false;
          _loadAd();
          _currentOrientation = orientation;
        }
        
        // 광고 크기가 고정되어 있으므로, 더 큰 컨테이너에 광고를 넣어서 확장된 모습처럼 표시
        final screenHeight = MediaQuery.of(context).size.height;
        final adHeight = screenHeight * 0.3; // 화면 높이의 30% (더 큰 값은 오버플로우 위험)
        
        return (_bannerAd != null && _isLoaded)
            // 광고 표시
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: adHeight, // 컨테이너는 크게 잡되
                color: Colors.transparent,
                alignment: Alignment.center, // 가운데 정렬
                child: Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              )
            // 광고 로드 전 빈 공간
            : const SizedBox(width: double.infinity, height: 0);
      },
    );
  }
} 