import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:inspirio/components/widgets.dart';
import 'package:inspirio/creator/creator_photo.dart';
import 'package:inspirio/pages/category.dart';
import 'package:inspirio/creator/creator.dart';
import 'package:inspirio/pages/pages.dart';
import 'package:inspirio/pages/poetry.dart';
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
final Reference popularRef =
    FirebaseStorage.instance.ref().child('home/popular');
final Reference hindiRef = FirebaseStorage.instance.ref().child('home/hindi');
final Reference morningRef =
    FirebaseStorage.instance.ref().child('home/morning');
final Reference motivationalRef =
    FirebaseStorage.instance.ref().child('home/motivational');
final Reference attitudeRef =
    FirebaseStorage.instance.ref().child('home/attitude');

List<Reference> foryouRefs = [];
List<Reference> popularRefs = [];
List<Reference> hindiRefs = [];
List<Reference> morningRefs = [];
List<Reference> motivationalRefs = [];
List<Reference> attitudeRefs = [];

class InspirioHome extends StatefulWidget {
  const InspirioHome({Key? key}) : super(key: key);

  @override
  State<InspirioHome> createState() => InspirioHomeState();
}

class InspirioHomeState extends State<InspirioHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late SharedPreferences _prefs;
  List<String> favoriteImages = [];

  final List<String> data = [
    "For You",
    "Popular",
    'Hindi',
    'Morning',
    "Motivational",
    "Attitude",
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoriteImages();
    _createBannerAd();
    _createInterstitialAd();
    loadNativeAd();
    _tabController = TabController(length: 6, vsync: this);
    refreshForYouImages();
    refreshPopularImages();
    refreshHindiImages();
    refreshMorningImages();
    refreshMotivationalImages();
    refreshAttitudeImages();
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
    _tabController.dispose();
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

  Future<void> refreshPopularImages() async {
    final ListResult result2 = await popularRef.listAll();
    final List<Reference> shuffledpopularRefs = result2.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        popularRefs = shuffledpopularRefs;
      });
    }
  }

  Future<void> refreshHindiImages() async {
    final ListResult result3 = await hindiRef.listAll();
    final List<Reference> shuffledhindiRefs = result3.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        hindiRefs = shuffledhindiRefs;
      });
    }
  }

  Future<void> refreshMorningImages() async {
    final ListResult result4 = await morningRef.listAll();
    final List<Reference> shuffledmorningRefs = result4.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        morningRefs = shuffledmorningRefs;
      });
    }
  }

  Future<void> refreshMotivationalImages() async {
    final ListResult result6 = await motivationalRef.listAll();
    final List<Reference> shuffledmotivationalRefs = result6.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        motivationalRefs = shuffledmotivationalRefs;
      });
    }
  }

  Future<void> refreshAttitudeImages() async {
    final ListResult result8 = await attitudeRef.listAll();
    final List<Reference> shuffledattitudeRefs = result8.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        attitudeRefs = shuffledattitudeRefs;
      });
    }
  }

  //banner Ads
  //native Ad
  //Interstitial Ad

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
                  child: NestedScrollView(
                    controller: ScrollController(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight:
                              MediaQuery.of(context).size.height * 0.1,
                          floating: true,
                          pinned: false,
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: false,
                            title: null,
                            background: Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .background
                                  .withOpacity(0.5),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Inspirio',
                                      style: GoogleFonts.cookie(
                                        // fontFamily: 'Anurati',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
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
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(_buildTabBar()),
                        ),
                      ];
                    },
                    body: _buildTabViews(),
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

  Widget _buildTabBar() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        Color primaryColour = themeProvider.themeData.colorScheme.primary;
        return Container(
          height: 100,
          color: themeProvider.themeData.colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
            child: TabBar(
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              physics: const BouncingScrollPhysics(),
              indicatorPadding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
              controller: _tabController,
              indicatorColor: themeProvider.themeData.colorScheme.secondary,
              indicator: BoxDecoration(
                color: themeProvider.themeData.colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: primaryColour,
              unselectedLabelColor: primaryColour,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 5),
              tabs: data.map((tab) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.046,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0,
                        color: themeProvider.themeData.colorScheme.secondary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Tab(
                    child: Text(
                      tab,
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        _buildForYouTab(),
        _buildPopularTab(),
        _buildHindiTab(),
        _buildMorningTab(),
        _buildMotivationalTab(),
        _buildAttitudeTab(),
      ],
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

  Widget _buildPopularTab() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return RefreshIndicator(
      backgroundColor: backgroundColour,
      color: primaryColour,
      onRefresh: refreshPopularImages,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index % 10 == 0 && index > 0) {
                  return _buildNativeAdWidget();
                } else {
                  final popularIndex = index - (index ~/ 10);
                  if (popularIndex < popularRefs.length) {
                    final pl = popularRefs[popularIndex];
                    return FutureBuilder<String>(
                      future: pl.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHindiTab() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return RefreshIndicator(
      backgroundColor: backgroundColour,
      color: primaryColour,
      onRefresh: refreshHindiImages,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index % 10 == 0 && index > 0) {
                  return _buildNativeAdWidget();
                } else {
                  final hindiIndex = index - (index ~/ 10);
                  if (hindiIndex < hindiRefs.length) {
                    final hi = hindiRefs[hindiIndex];
                    return FutureBuilder<String>(
                      future: hi.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningTab() {
    return RefreshIndicator(
      onRefresh: refreshMorningImages,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index % 10 == 0 && index > 0) {
                  return _buildNativeAdWidget();
                } else {
                  final morningIndex = index - (index ~/ 10);
                  if (morningIndex < morningRefs.length) {
                    final mr = morningRefs[morningIndex];
                    return FutureBuilder<String>(
                      future: mr.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  // else {
  //   return const Center(child: Text('No images available'));
  // }

  Widget _buildMotivationalTab() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return RefreshIndicator(
      backgroundColor: backgroundColour,
      color: primaryColour,
      onRefresh: refreshMotivationalImages,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index % 10 == 0 && index > 0) {
                  return _buildNativeAdWidget();
                } else {
                  final motivationalIndex = index - (index ~/ 10);
                  if (motivationalIndex < motivationalRefs.length) {
                    final mo = motivationalRefs[motivationalIndex];
                    return FutureBuilder<String>(
                      future: mo.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttitudeTab() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return RefreshIndicator(
      backgroundColor: backgroundColour,
      color: primaryColour,
      onRefresh: refreshAttitudeImages,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index % 10 == 0 && index > 0) {
                  return _buildNativeAdWidget();
                } else {
                  final attitudeIndex = index - (index ~/ 10);
                  if (attitudeIndex < attitudeRefs.length) {
                    final at = attitudeRefs[attitudeIndex];
                    return FutureBuilder<String>(
                      future: at.getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  // else {
  //   return const Center(child: Text('No images available'));
  // }

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
                              Get.to(
                                 InspirioEditor(imageUrl: imageUrl,),
                              );
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Iconsax.pen_add,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
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
            // Positioned(
            //   bottom: 50,
            //   left: 0,
            //   right: 0,
            //   child: Align(
            //     alignment: Alignment.center,
            //     child: Text(
            //       'Inspirio',
            //       style: GoogleFonts.orbitron(
            //         // fontFamily: 'Anurati',
            //         color: Theme.of(context).colorScheme.secondary,
            //         fontSize: 30,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),

            //  LoadingAnimationWidget.threeArchedCircle(
            //   size: 50,
            //   color: Colors.red,
            //   // leftDotColor: Colors.red,
            //   // rightDotColor: Colors.white,
            // ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tab;

  _SliverAppBarDelegate(this.tab);

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return tab;
  }
}
