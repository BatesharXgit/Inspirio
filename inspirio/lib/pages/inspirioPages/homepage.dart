import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:inspirio/components/widgets.dart';
import 'package:inspirio/pages/inspirioPages/category.dart';
import 'package:inspirio/pages/inspirioPages/creator.dart';
import 'package:inspirio/pages/inspirioPages/pages.dart';
import 'package:inspirio/pages/inspirioPages/poetry.dart';
import 'package:inspirio/services/admob_services.dart';
import 'package:inspirio/util/favourites.dart';
import 'package:inspirio/util/settings.dart';
import 'package:inspirio/util/theme_provider.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:inspirio/services/ad_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:share/share.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey _globalKey = GlobalKey();

Future<void> shareQuotes(String imageUrl) async {
  try {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/Image.png';
      final file = File(filePath);

      await file.writeAsBytes(pngBytes);

      await Share.shareFiles([filePath]);
    }
    // ignore: empty_catches
  } catch (e) {}
}

void savetoGallery(BuildContext context) async {
  try {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final externalDir = await getExternalStorageDirectory();
      final filePath = '${externalDir!.path}/InspirioImage.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      final result = await ImageGallerySaver.saveFile(filePath);

      if (result['isSuccess']) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF131321),
            content: Text(
              'Successfully saved to gallery 😊',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {}
    }
    // ignore: empty_catches
  } catch (e) {}
}

final FirebaseStorage storage = FirebaseStorage.instance;
final Reference foryouRef = FirebaseStorage.instance.ref().child('home/foryou');

List<Reference> foryouRefs = [];

class InspirioHomeNew extends StatefulWidget {
  const InspirioHomeNew({Key? key}) : super(key: key);

  @override
  State<InspirioHomeNew> createState() => InspirioHomeNewState();
}

class InspirioHomeNewState extends State<InspirioHomeNew> {
  late SharedPreferences _prefs;
  List<String> favoriteImages = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteImages();
    _createBannerAd();
    _createInterstitialAd();
    loadNativeAd();
    refreshForYouImages();
    isImageLoaded = true;
  }

  BannerAd? _banner;
  InterstitialAd? _interstitialAd;
  void _createBannerAd() {
    _banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerListener,
      request: const AdRequest(),
    )..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  void loadNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: AdMobService.nativeAdsUnit!,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
          onAdClicked: (ad) {},
          onAdImpression: (ad) {},
          onAdClosed: (ad) {},
          onAdOpened: (ad) {},
          onAdWillDismissScreen: (ad) {},
          onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
        ),
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.medium),
        customOptions: {});
    _nativeAd?.load();
  }

  Widget _buildNativeAdWidget() {
    if (_nativeAdIsLoaded) {
      return NativeAdWidget(_nativeAd!);
    } else {
      return Container();
    }
  }

  late bool isImageLoaded = false;

  Future<void> _loadFavoriteImages() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteImages = _prefs.getStringList('favoriteImages') ?? [];
    });
  }

  void toggleFavorite(String imageUrl) {
    setState(() {
      if (favoriteImages.contains(imageUrl)) {
        favoriteImages.remove(imageUrl);
      } else {
        favoriteImages.add(imageUrl);
      }
    });
    _prefs.setStringList('favoriteImages', favoriteImages);
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshForYouImages() async {
    final ListResult result1 = await foryouRef.listAll();
    final List<Reference> shuffledforyourefs = result1.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        foryouRefs = shuffledforyourefs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        Color backgroundColour = themeProvider.themeData.colorScheme.background;
        Color primaryColour = themeProvider.themeData.colorScheme.primary;
        return Scaffold(
          key: _scaffoldKey,
          appBar: null,
          bottomNavigationBar: _banner == null
              ? const SizedBox(
                  height: 0,
                )
              : SizedBox(
                  height: 52,
                  child: AdWidget(ad: _banner!),
                ),
          backgroundColor: backgroundColour,
          body: FutureBuilder<ListResult>(
            future: foryouRef.listAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              } else {
                return SafeArea(
                  child: Column(
                    children: [
                      Container(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Inspirio',
                                style: GoogleFonts.cookie(
                                  // fontFamily: 'Anurati',
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 44,
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.heart,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 28,
                                    ),
                                    onPressed: () => Get.to(
                                      const FavouritesQuotesPage(),
                                      transition:
                                          Transition.rightToLeftWithFade,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.setting,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 28,
                                    ),
                                    onPressed: () => Get.to(
                                      const SettingsPage(),
                                      transition:
                                          Transition.leftToRightWithFade,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text("For You"),
                      Expanded(child: _buildForYouTab()),
                    ],
                  ),
                );
              }
            },
          ),
          floatingActionButton: FutureBuilder<ListResult>(
            future: foryouRef.listAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: 1,
                      backgroundColor: primaryColour,
                      onPressed: () => Get.to(
                        const Category(),
                        transition: Transition.downToUp,
                      ),
                      child: Icon(
                        Iconsax.quote_up_square,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    FloatingActionButton(
                      heroTag: 2,
                      backgroundColor: primaryColour,
                      onPressed: () => Get.to(
                        const PoetryPage(),
                        transition: Transition.downToUp,
                      ),
                      child: Icon(
                        Iconsax.note_1,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 8.0,
                    ),
                    FloatingActionButton.extended(
                      backgroundColor: primaryColour,
                      onPressed: () => Get.to(
                        const InspirioCreator(),
                        transition: Transition.topLevel,
                      ),
                      heroTag: 3,
                      label: Text(
                        'Create',
                        style: GoogleFonts.kanit(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18),
                      ),
                      icon: Icon(
                        Iconsax.magicpen,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildForYouTab() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;

    return RefreshIndicator(
      backgroundColor: backgroundColour,
      color: primaryColour,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final fyIndex = index - (index ~/ 10);
                if (fyIndex < foryouRefs.length) {
                  final fy = foryouRefs[fyIndex];
                  return FutureBuilder<String>(
                    future: fy.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        return _buildImageWidget(snapshot.data!);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        Color primaryColour = themeProvider.themeData.colorScheme.primary;
        final heroTag = 'image_hero_$imageUrl';

        return Hero(
          tag: heroTag,
          child: GestureDetector(
            onTap: () {
              _showFullScreenImage(imageUrl, heroTag, themeProvider);
            },
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColour.withOpacity(0.2),
                      blurRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 100),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    imageUrl: imageUrl,
                    placeholder: (context, url) =>
                        Components.buildPlaceholder(),
                    errorWidget: (context, url, error) =>
                        Components.buildErrorWidget(),
                    fit: BoxFit.cover,
                    cacheManager: DefaultCacheManager(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(
      String imageUrl, String heroTag, ThemeProvider themeProvider) {
    Color backgroundColour = themeProvider.themeData.colorScheme.background;
    Color primaryColour = themeProvider.themeData.colorScheme.primary;
    Color secondaryColour = themeProvider.themeData.colorScheme.secondary;

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            backgroundColor: backgroundColour,
            body: SafeArea(
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    Navigator.of(context).pop();
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      color: backgroundColour,
                      child: Center(
                        child: Hero(
                          tag: heroTag,
                          child: RepaintBoundary(
                            key: _globalKey,
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  Components.buildPlaceholder(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.contain,
                              cacheManager: DefaultCacheManager(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10.0,
                      bottom: 10.0,
                      child: Row(
                        children: [
                          FloatingActionButton(
                            backgroundColor: primaryColour,
                            onPressed: () {
                              _showInterstitialAd();
                              setState(() {
                                if (favoriteImages.contains(imageUrl)) {
                                  favoriteImages.remove(imageUrl);
                                } else {
                                  favoriteImages.add(imageUrl);
                                }
                              });
                              _prefs.setStringList(
                                  'favoriteImages', favoriteImages);
                            },
                            heroTag: 1,
                            child: Icon(
                              favoriteImages.contains(imageUrl)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: secondaryColour,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          FloatingActionButton(
                            backgroundColor: primaryColour,
                            heroTag: 2,
                            onPressed: () {
                              _showInterstitialAd();
                              savetoGallery(context);
                            },
                            child: Icon(
                              Iconsax.arrow_down,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          FloatingActionButton.extended(
                            backgroundColor: primaryColour,
                            onPressed: () {
                              _showInterstitialAd();
                              shareQuotes(imageUrl);
                            },
                            heroTag: 3,
                            icon: Icon(
                              Iconsax.share,
                              color: secondaryColour,
                            ),
                            label: Text(
                              'Share',
                              style: TextStyle(color: secondaryColour),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
