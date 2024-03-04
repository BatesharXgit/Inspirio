import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2502922311219626/4053418395';
      // return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2502922311219626/1931007304';
    }
    return null;
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2502922311219626/7118565430';
      // return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2502922311219626/7644985525';
    }
    return null;
  }

  static String? get nativeAdsUnit {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2502922311219626/1585937070';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2247696110';
    }
    return null;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
      onAdLoaded: (ad) => debugPrint('Banner Ad Loaded'),
      onAdFailedToLoad: ((ad, error) {
        ad.dispose();
        debugPrint('Banner Ad failed to load: $error');
      }),
      onAdOpened: ((ad) => debugPrint("Banner ad opened")));
}
