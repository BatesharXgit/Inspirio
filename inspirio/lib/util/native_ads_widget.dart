import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatelessWidget {
  final NativeAd _nativeAd;

  const NativeAdWidget(this._nativeAd, {super.key});

  @override
  Widget build(BuildContext context) {
    return AdWidget(ad: _nativeAd);
  }
}
