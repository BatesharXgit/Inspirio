// import 'dart:ui' as ui;
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:inspirio/components/widgets.dart';
// import 'package:inspirio/pages/category.dart';
// import 'package:inspirio/services/admob_services.dart';
// // import 'package:google_mobile_ads/google_mobile_ads.dart';
// // import 'package:inspirio/services/ad_provider.dart';
// import 'package:path_provider/path_provider.dart';
// // import 'package:provider/provider.dart';
// import 'package:share/share.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// // ignore: depend_on_referenced_packages
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// final FirebaseStorage storage = FirebaseStorage.instance;
// final Reference shakespeareRef =
//     FirebaseStorage.instance.ref().child('poeters/william');
// final Reference rabindernathRef =
//     FirebaseStorage.instance.ref().child('poeters/tagore');
// final Reference gulzarRef =
//     FirebaseStorage.instance.ref().child('poeters/gulzar');
// final Reference emilyRef =
//     FirebaseStorage.instance.ref().child('poeters/emily');
// final Reference mirzaRef =
//     FirebaseStorage.instance.ref().child('poeters/mirza');
// final Reference robertRef =
//     FirebaseStorage.instance.ref().child('poeters/frost');
// final Reference pabloRef =
//     FirebaseStorage.instance.ref().child('poeters/pablo');

// BannerAd? _banner;
// InterstitialAd? _interstitialAd;
// void _createBannerAd() {
//   _banner = BannerAd(
//     size: AdSize.fullBanner,
//     adUnitId: AdMobService.bannerAdUnitId!,
//     listener: AdMobService.bannerListener,
//     request: const AdRequest(),
//   )..load();
// }

// void _createInterstitialAd() {
//   InterstitialAd.load(
//     adUnitId: AdMobService.interstitialAdUnitId!,
//     request: const AdRequest(),
//     adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (ad) => _interstitialAd = ad,
//         onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null),
//   );
// }

// void _showInterstitialAd() {
//   if (_interstitialAd != null) {
//     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdDismissedFullScreenContent: (ad) {
//         ad.dispose();
//         _createInterstitialAd();
//       },
//       onAdFailedToShowFullScreenContent: (ad, error) {
//         ad.dispose();
//         _createInterstitialAd();
//       },
//     );
//     _interstitialAd!.show();
//     _interstitialAd = null;
//   }
// }

// List<Reference> shakespeareRefs = [];
// List<Reference> rabindernathRefs = [];
// List<Reference> gulzarRefs = [];
// List<Reference> emilyRefs = [];
// List<Reference> mirzaRefs = [];
// List<Reference> robertRefs = [];
// List<Reference> pabloRefs = [];

// late TabController _tabController;
// final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// final GlobalKey _globalKey = GlobalKey();

// late SharedPreferences _prefs;
// List<String> favoriteImages = [];

// void savetoGallery(BuildContext context) async {
//   try {
//     RenderRepaintBoundary boundary =
//         _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//     if (byteData != null) {
//       Uint8List pngBytes = byteData.buffer.asUint8List();
//       final externalDir = await getExternalStorageDirectory();
//       final filePath = '${externalDir!.path}/InspirioImage.png';
//       final file = File(filePath);
//       await file.writeAsBytes(pngBytes);
//       final result = await ImageGallerySaver.saveFile(filePath);

//       if (result['isSuccess']) {
//         // ignore: use_build_context_synchronously
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             backgroundColor: Color(0xFF131321),
//             content: Text(
//               'Successfully saved to gallery 😊',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         );
//       } else {}
//     }
//     // ignore: empty_catches
//   } catch (e) {}
// }

// Future<void> shareQuotes(String imageUrl) async {
//   try {
//     RenderRepaintBoundary boundary =
//         _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//     if (byteData != null) {
//       Uint8List pngBytes = byteData.buffer.asUint8List();
//       final tempDir = await getTemporaryDirectory();
//       final filePath = '${tempDir.path}/Image.png';
//       final file = File(filePath);

//       await file.writeAsBytes(pngBytes);

//       await Share.shareFiles([filePath]);
//     }
//     // ignore: empty_catches
//   } catch (e) {}
// }

// class ShakespearePage extends StatefulWidget {
//   const ShakespearePage({Key? key}) : super(key: key);

//   @override
//   ShakespearePageState createState() => ShakespearePageState();
// }

// class ShakespearePageState extends State<ShakespearePage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Widget _buildNativeAdWidget() {
//     if (_nativeAdIsLoaded) {
//       return NativeAdWidget(_nativeAd!);
//     } else {
//       return Container();
//     }
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await shakespeareRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         shakespeareRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         iconTheme: Theme.of(context).iconTheme,
//         elevation: 8,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'William Shakespeare',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < shakespeareRefs.length) {
//                               final fy = shakespeareRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(
//     String imageUrl,
//     String heroTag,
//   ) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     final heroTag = 'image_hero_$imageUrl';

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               FloatingActionButton(
//                                 backgroundColor: backgroundColour,
//                                 heroTag: 2,
//                                 onPressed: () {
//                                   _showInterstitialAd();
//                                   savetoGallery(context);
//                                 },
//                                 child: Icon(
//                                   Iconsax.arrow_down,
//                                   color:
//                                       Theme.of(context).colorScheme.secondary,
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 10,
//                               ),
                              
//                               SizedBox(
//                                 height: 10,
//                               ),
//                               FloatingActionButton.extended(
//                                 backgroundColor: backgroundColour,
//                                 onPressed: () {
//                                   _showInterstitialAd();
//                                   shareQuotes(imageUrl);
//                                 },
//                                 heroTag: 3,
//                                 icon: Icon(
//                                   Iconsax.share,
//                                   color:
//                                       Theme.of(context).colorScheme.secondary,
//                                 ),
//                                 label: Text(
//                                   'Share',
//                                   style: TextStyle(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .secondary),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class RabindernathPage extends StatefulWidget {
//   const RabindernathPage({Key? key}) : super(key: key);

//   @override
//   RabindernathPageState createState() => RabindernathPageState();
// }

// class RabindernathPageState extends State<RabindernathPage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Widget _buildNativeAdWidget() {
//     if (_nativeAdIsLoaded) {
//       return NativeAdWidget(_nativeAd!);
//     } else {
//       return Container();
//     }
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await rabindernathRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         rabindernathRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         iconTheme: Theme.of(context).iconTheme,
//         centerTitle: false,
//         elevation: 8,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'Rabindernath Tagore',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < rabindernathRefs.length) {
//                               final fy = rabindernathRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl, String heroTag) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         children: [
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               setState(() {
//                                 if (favoriteImages.contains(imageUrl)) {
//                                   favoriteImages.remove(imageUrl);
//                                 } else {
//                                   favoriteImages.add(imageUrl);
//                                 }
//                               });
//                               _prefs.setStringList(
//                                   'favoriteImages', favoriteImages);
//                             },
//                             heroTag: 1,
//                             child: Icon(
//                               favoriteImages.contains(imageUrl)
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: secondaryColour,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             heroTag: 2,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               savetoGallery(context);
//                             },
//                             child: Icon(
//                               Iconsax.arrow_down,
//                               color: Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton.extended(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               shareQuotes(imageUrl);
//                             },
//                             heroTag: 3,
//                             icon: Icon(
//                               Iconsax.share,
//                               color: secondaryColour,
//                             ),
//                             label: Text(
//                               'Share',
//                               style: TextStyle(color: secondaryColour),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class GulzarPage extends StatefulWidget {
//   const GulzarPage({Key? key}) : super(key: key);

//   @override
//   GulzarPageState createState() => GulzarPageState();
// }

// class GulzarPageState extends State<GulzarPage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Widget _buildNativeAdWidget() {
//     if (_nativeAdIsLoaded) {
//       return NativeAdWidget(_nativeAd!);
//     } else {
//       return Container();
//     }
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await gulzarRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         gulzarRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         centerTitle: false,
//         iconTheme: Theme.of(context).iconTheme,
//         elevation: 8,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'Gulzar',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < gulzarRefs.length) {
//                               final fy = gulzarRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl, String heroTag) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         children: [
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               setState(() {
//                                 if (favoriteImages.contains(imageUrl)) {
//                                   favoriteImages.remove(imageUrl);
//                                 } else {
//                                   favoriteImages.add(imageUrl);
//                                 }
//                               });
//                               _prefs.setStringList(
//                                   'favoriteImages', favoriteImages);
//                             },
//                             heroTag: 1,
//                             child: Icon(
//                               favoriteImages.contains(imageUrl)
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: secondaryColour,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             heroTag: 2,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               savetoGallery(context);
//                             },
//                             child: Icon(
//                               Iconsax.arrow_down,
//                               color: Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton.extended(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               shareQuotes(imageUrl);
//                             },
//                             heroTag: 3,
//                             icon: Icon(
//                               Iconsax.share,
//                               color: secondaryColour,
//                             ),
//                             label: Text(
//                               'Share',
//                               style: TextStyle(color: secondaryColour),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class EmilyPage extends StatefulWidget {
//   const EmilyPage({Key? key}) : super(key: key);

//   @override
//   EmilyPageState createState() => EmilyPageState();
// }

// class EmilyPageState extends State<EmilyPage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Widget _buildNativeAdWidget() {
//     if (_nativeAdIsLoaded) {
//       return NativeAdWidget(_nativeAd!);
//     } else {
//       return Container();
//     }
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await emilyRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         emilyRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         centerTitle: false,
//         elevation: 8,
//         iconTheme: Theme.of(context).iconTheme,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'Emily Dickinson',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < emilyRefs.length) {
//                               final fy = emilyRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl, String heroTag) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         children: [
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               setState(() {
//                                 if (favoriteImages.contains(imageUrl)) {
//                                   favoriteImages.remove(imageUrl);
//                                 } else {
//                                   favoriteImages.add(imageUrl);
//                                 }
//                               });
//                               _prefs.setStringList(
//                                   'favoriteImages', favoriteImages);
//                             },
//                             heroTag: 1,
//                             child: Icon(
//                               favoriteImages.contains(imageUrl)
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: secondaryColour,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             heroTag: 2,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               savetoGallery(context);
//                             },
//                             child: Icon(
//                               Iconsax.arrow_down,
//                               color: Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton.extended(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               shareQuotes(imageUrl);
//                             },
//                             heroTag: 3,
//                             icon: Icon(
//                               Iconsax.share,
//                               color: secondaryColour,
//                             ),
//                             label: Text(
//                               'Share',
//                               style: TextStyle(color: secondaryColour),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class MirzaPage extends StatefulWidget {
//   const MirzaPage({Key? key}) : super(key: key);

//   @override
//   MirzaPageState createState() => MirzaPageState();
// }

// class MirzaPageState extends State<MirzaPage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Widget _buildNativeAdWidget() {
//     if (_nativeAdIsLoaded) {
//       return NativeAdWidget(_nativeAd!);
//     } else {
//       return Container();
//     }
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await mirzaRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         mirzaRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         centerTitle: false,
//         elevation: 8,
//         iconTheme: Theme.of(context).iconTheme,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'Mirza Ghalib',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < mirzaRefs.length) {
//                               final fy = mirzaRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl, String heroTag) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         children: [
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               setState(() {
//                                 if (favoriteImages.contains(imageUrl)) {
//                                   favoriteImages.remove(imageUrl);
//                                 } else {
//                                   favoriteImages.add(imageUrl);
//                                 }
//                               });
//                               _prefs.setStringList(
//                                   'favoriteImages', favoriteImages);
//                             },
//                             heroTag: 1,
//                             child: Icon(
//                               favoriteImages.contains(imageUrl)
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: secondaryColour,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             heroTag: 2,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               savetoGallery(context);
//                             },
//                             child: Icon(
//                               Iconsax.arrow_down,
//                               color: Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton.extended(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               shareQuotes(imageUrl);
//                             },
//                             heroTag: 3,
//                             icon: Icon(
//                               Iconsax.share,
//                               color: secondaryColour,
//                             ),
//                             label: Text(
//                               'Share',
//                               style: TextStyle(color: secondaryColour),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class RobertPage extends StatefulWidget {
//   const RobertPage({Key? key}) : super(key: key);

//   @override
//   RobertPageState createState() => RobertPageState();
// }

// class RobertPageState extends State<RobertPage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Widget _buildNativeAdWidget() {
//     if (_nativeAdIsLoaded) {
//       return NativeAdWidget(_nativeAd!);
//     } else {
//       return Container();
//     }
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await robertRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         robertRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         centerTitle: false,
//         iconTheme: Theme.of(context).iconTheme,
//         elevation: 8,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'Robert Frost',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < robertRefs.length) {
//                               final fy = robertRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl, String heroTag) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         children: [
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               setState(() {
//                                 if (favoriteImages.contains(imageUrl)) {
//                                   favoriteImages.remove(imageUrl);
//                                 } else {
//                                   favoriteImages.add(imageUrl);
//                                 }
//                               });
//                               _prefs.setStringList(
//                                   'favoriteImages', favoriteImages);
//                             },
//                             heroTag: 1,
//                             child: Icon(
//                               favoriteImages.contains(imageUrl)
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: secondaryColour,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             heroTag: 2,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               savetoGallery(context);
//                             },
//                             child: Icon(
//                               Iconsax.arrow_down,
//                               color: Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton.extended(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               shareQuotes(imageUrl);
//                             },
//                             heroTag: 3,
//                             icon: Icon(
//                               Iconsax.share,
//                               color: secondaryColour,
//                             ),
//                             label: Text(
//                               'Share',
//                               style: TextStyle(color: secondaryColour),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class PabloPage extends StatefulWidget {
//   const PabloPage({Key? key}) : super(key: key);

//   @override
//   PabloPageState createState() => PabloPageState();
// }

// class PabloPageState extends State<PabloPage>
//     with SingleTickerProviderStateMixin {
//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteImages();
//     _createBannerAd();
//     _createInterstitialAd();
//     loadNativeAd();
//     _tabController = TabController(length: 2, vsync: this);
//     shuffleImages();
//   }

//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;

//   void loadNativeAd() {
//     _nativeAd = NativeAd(
//         adUnitId: AdMobService.nativeAdsUnit!,
//         listener: NativeAdListener(
//           onAdLoaded: (ad) {
//             setState(() {
//               _nativeAdIsLoaded = true;
//             });
//           },
//           onAdFailedToLoad: (ad, error) {
//             ad.dispose();
//           },
//           onAdClicked: (ad) {},
//           onAdImpression: (ad) {},
//           onAdClosed: (ad) {},
//           onAdOpened: (ad) {},
//           onAdWillDismissScreen: (ad) {},
//           onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
//         ),
//         request: const AdRequest(),
//         nativeTemplateStyle:
//             NativeTemplateStyle(templateType: TemplateType.medium),
//         customOptions: {});
//     _nativeAd?.load();
//   }

//   Future<void> _loadFavoriteImages() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
//     });
//   }

//   void toggleFavorite(String imageUrl) {
//     setState(() {
//       if (favoriteImages.contains(imageUrl)) {
//         favoriteImages.remove(imageUrl);
//       } else {
//         favoriteImages.add(imageUrl);
//       }
//     });
//     _prefs.setStringList('favoriteImages', favoriteImages);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> shuffleImages() async {
//     final ListResult result = await pabloRef.listAll();
//     final List<Reference> shuffledforyourefs = result.items.toList()..shuffle();
//     if (mounted) {
//       setState(() {
//         pabloRefs = shuffledforyourefs;
//       });
//     }
//   }

//   Future<void> refreshImages() async {
//     await shuffleImages();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;
//     return Scaffold(
//       bottomNavigationBar: _banner == null
//           ? const SizedBox(
//               height: 0,
//             )
//           : SizedBox(
//               height: 52,
//               child: AdWidget(ad: _banner!),
//             ),
//       appBar: AppBar(
//         centerTitle: false,
//         iconTheme: Theme.of(context).iconTheme,
//         elevation: 8,
//         backgroundColor: backgroundColour,
//         title: Text(
//           'Pablo Neruda',
//           style: GoogleFonts.kanit(
//             color: secondaryColour,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       key: _scaffoldKey,
//       backgroundColor: backgroundColour,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: RefreshIndicator(
//                 backgroundColor: backgroundColour,
//                 color: secondaryColour,
//                 onRefresh: refreshImages,
//                 child: CustomScrollView(
//                   slivers: <Widget>[
//                     SliverGrid(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         childAspectRatio: 0.8,
//                       ),
//                       delegate: SliverChildBuilderDelegate(
//                         (BuildContext context, int index) {
//                           if (index % 10 == 0 && index > 0) {
//                             return _buildNativeAdWidget();
//                           } else {
//                             final fyIndex = index - (index ~/ 10);
//                             if (fyIndex < pabloRefs.length) {
//                               final fy = pabloRefs[fyIndex];
//                               return FutureBuilder<String>(
//                                 future: fy.getDownloadURL(),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting) {
//                                     return Components.buildPlaceholder();
//                                   } else if (snapshot.hasError) {
//                                     return Components.buildErrorWidget();
//                                   } else if (snapshot.hasData) {
//                                     return _buildImageWidget(snapshot.data!);
//                                   } else {
//                                     return Container();
//                                   }
//                                 },
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImageWidget(String imageUrl) {
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     final heroTag = 'image_hero_$imageUrl';

//     return Hero(
//       tag: heroTag,
//       child: GestureDetector(
//         onTap: () {
//           _showFullScreenImage(imageUrl, heroTag);
//         },
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColour.withOpacity(0.2),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8.0),
//               child: CachedNetworkImage(
//                 fadeInDuration: const Duration(milliseconds: 100),
//                 fadeOutDuration: const Duration(milliseconds: 100),
//                 imageUrl: imageUrl,
//                 placeholder: (context, url) => Components.buildPlaceholder(),
//                 errorWidget: (context, url, error) =>
//                     Components.buildErrorWidget(),
//                 fit: BoxFit.cover,
//                 cacheManager: DefaultCacheManager(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl, String heroTag) {
//     Color backgroundColour = Theme.of(context).colorScheme.background;
//     Color primaryColour = Theme.of(context).colorScheme.primary;
//     Color secondaryColour = Theme.of(context).colorScheme.secondary;

//     Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (BuildContext context, _, __) {
//           return Scaffold(
//             backgroundColor: backgroundColour,
//             body: SafeArea(
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//                 child: Stack(
//                   children: [
//                     Container(
//                       color: backgroundColour,
//                       child: Center(
//                         child: Hero(
//                           tag: heroTag,
//                           child: RepaintBoundary(
//                             key: _globalKey,
//                             child: CachedNetworkImage(
//                               imageUrl: imageUrl,
//                               placeholder: (context, url) =>
//                                   Components.buildPlaceholder(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                               fit: BoxFit.contain,
//                               cacheManager: DefaultCacheManager(),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       right: 10.0,
//                       bottom: 10.0,
//                       child: Row(
//                         children: [
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               setState(() {
//                                 if (favoriteImages.contains(imageUrl)) {
//                                   favoriteImages.remove(imageUrl);
//                                 } else {
//                                   favoriteImages.add(imageUrl);
//                                 }
//                               });
//                               _prefs.setStringList(
//                                   'favoriteImages', favoriteImages);
//                             },
//                             heroTag: 1,
//                             child: Icon(
//                               favoriteImages.contains(imageUrl)
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: secondaryColour,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton(
//                             backgroundColor: primaryColour,
//                             heroTag: 2,
//                             onPressed: () {
//                               _showInterstitialAd();
//                               savetoGallery(context);
//                             },
//                             child: Icon(
//                               Iconsax.arrow_down,
//                               color: Theme.of(context).colorScheme.secondary,
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           FloatingActionButton.extended(
//                             backgroundColor: primaryColour,
//                             onPressed: () {
//                               shareQuotes(imageUrl);
//                             },
//                             heroTag: 3,
//                             icon: Icon(
//                               Iconsax.share,
//                               color: secondaryColour,
//                             ),
//                             label: Text(
//                               'Share',
//                               style: TextStyle(color: secondaryColour),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
