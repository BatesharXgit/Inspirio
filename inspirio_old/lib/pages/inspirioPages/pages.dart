import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:inspirio/components/widgets.dart';
import 'package:inspirio/services/admob_services.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:inspirio/services/ad_provider.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final Reference morningRef = storage.ref().child("home/morning");
final Reference nightRef = storage.ref().child("category/night");
final Reference birthdayRef = storage.ref().child("category/birthday");
final Reference inspirationalRef =
    storage.ref().child("category/inspirational");
final Reference religiousRef = storage.ref().child("category/religious");
final Reference leadershipRef = storage.ref().child("category/leadership");
final Reference avengersRef = storage.ref().child("category/avengers");
final Reference happinessRef = storage.ref().child("category/happiness");
final Reference moviesRef = storage.ref().child("category/movies");
final Reference hindiRef = storage.ref().child("home/hindi");
final Reference bestWishesRef = storage.ref().child("category/bestwishes");
final Reference friendshipRef = storage.ref().child("category/friendship");
final Reference successRef = storage.ref().child("category/success");
final Reference motivationalRef = storage.ref().child("home/motivational");
final Reference fitnessRef = storage.ref().child("category/fitness");
final Reference natureRef = storage.ref().child("category/nature");
final Reference courageRef = storage.ref().child("category/courage");
final Reference businessRef = storage.ref().child("category/business");
final Reference powerRef = storage.ref().child("category/power");
final Reference wisdomRef = storage.ref().child("category/wisdom");

List<Reference> morningRefs = [];
List<Reference> nightRefs = [];
List<Reference> birthdayRefs = [];
List<Reference> inspirationalRefs = [];
List<Reference> religiousRefs = [];
List<Reference> leadershipRefs = [];
List<Reference> happinessRefs = [];
List<Reference> moviesRefs = [];
List<Reference> hindiRefs = [];
List<Reference> bestwishesRefs = [];
List<Reference> friendshipRefs = [];
List<Reference> successRefs = [];
List<Reference> motivationalRefs = [];
List<Reference> fitnessRefs = [];
List<Reference> natureRefs = [];
List<Reference> courageRefs = [];
List<Reference> businessRefs = [];
List<Reference> powerRefs = [];
List<Reference> wisdomRefs = [];

late SharedPreferences _prefs;
List<String> favoriteImages = [];

late TabController _tabController;
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey _globalKey = GlobalKey();

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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Morning Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class MorningPage extends StatefulWidget {
  const MorningPage({Key? key}) : super(key: key);

  @override
  MorningPageState createState() => MorningPageState();
}

class MorningPageState extends State<MorningPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result1 = await morningRef.listAll();
    final List<Reference> shuffledmorningrefs = result1.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        morningRefs = shuffledmorningrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Morning',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < morningRefs.length) {
                              final fy = morningRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Night Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class NightPage extends StatefulWidget {
  const NightPage({Key? key}) : super(key: key);

  @override
  NightPageState createState() => NightPageState();
}

class NightPageState extends State<NightPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await nightRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        nightRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Night',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < nightRefs.length) {
                              final fy = nightRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Birthday Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class BirthdayPage extends StatefulWidget {
  const BirthdayPage({Key? key}) : super(key: key);

  @override
  BirthdayPageState createState() => BirthdayPageState();
}

class BirthdayPageState extends State<BirthdayPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await birthdayRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        birthdayRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Birthday',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < birthdayRefs.length) {
                              final fy = birthdayRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Religion Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class ReligiousPage extends StatefulWidget {
  const ReligiousPage({Key? key}) : super(key: key);

  @override
  ReligiousPageState createState() => ReligiousPageState();
}

class ReligiousPageState extends State<ReligiousPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await religiousRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        religiousRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Religious',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < religiousRefs.length) {
                              final fy = religiousRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Happiness Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class HappinessPage extends StatefulWidget {
  const HappinessPage({Key? key}) : super(key: key);

  @override
  HappinessPageState createState() => HappinessPageState();
}

class HappinessPageState extends State<HappinessPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await happinessRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        happinessRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Happiness',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < happinessRefs.length) {
                              final fy = happinessRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Inspirational Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class InspirationalPage extends StatefulWidget {
  const InspirationalPage({Key? key}) : super(key: key);

  @override
  InspirationalPageState createState() => InspirationalPageState();
}

class InspirationalPageState extends State<InspirationalPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await inspirationalRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        inspirationalRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Inspirational',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < inspirationalRefs.length) {
                              final fy = inspirationalRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Leadership Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class LeadershipPage extends StatefulWidget {
  const LeadershipPage({Key? key}) : super(key: key);

  @override
  LeadershipPageState createState() => LeadershipPageState();
}

class LeadershipPageState extends State<LeadershipPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await leadershipRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        leadershipRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Leadership',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < leadershipRefs.length) {
                              final fy = leadershipRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Avengers Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class AvengersPage extends StatefulWidget {
  const AvengersPage({Key? key}) : super(key: key);

  @override
  AvengersPageState createState() => AvengersPageState();
}

class AvengersPageState extends State<AvengersPage> {
  List<String> avengersURLs = [];
  bool isLoading = false;
  List<String> avengersQuotes = [
    "I am Iron Man.\n- Tony Stark",
    "I can do this all day.\n- Steve Rogers",
    "I'm always angry.\n- Bruce Banner",
    "There's only one God, ma'am, and I'm pretty sure he doesn't dress like that.\n- Captain America",
    "I am burdened with glorious purpose.\n- Loki",
    "We have a Hulk.\n- Tony Stark",
    "I understood that reference.\n- Steve Rogers",
    "I'm just a kid from Brooklyn.\n- Steve Rogers",
    "I'm always looking for trouble.\n- Tony Stark",
    "I could do this all day.\n- Steve Rogers",
    "I've got red in my ledger. I'd like to wipe it out.\n- Natasha Romanoff",
    "Genius, billionaire, playboy, philanthropist.\n- Tony Stark",
    "I'm not a hero. I'm a high-functioning disaster.\n- Tony Stark",
    "I'm just a guy who cares too much.\n- Vision",
    "It's not about how much we lost, it's about how much we have left.\n- Tony Stark",
    "You're a laboratory experiment, Rogers. Everything special about you came out of a bottle.\n- Tony Stark",
    "I can't control their fear, only my own.\n- Wanda Maximoff",
    "I am Groot.\n- Groot",
    "I don't see how that's a party.\n- Clint Barton",
    "I'm with you 'til the end of the line.\n- Steve Rogers",
    "Heroes are made by the path they choose, not the powers they are graced with.\n- Tony Stark",
    "I can do it. I can do this all day.\n- Sam Wilson",
    "I'm not a hero. I'm a high-functioning sociopath.\n- Tony Stark",
    "I had strings, but now I'm free.\n- Ultron",
    "I'm sorry, did I step on your moment?\n- Tony Stark",
    "That's my secret, Cap. I'm always angry.\n- Bruce Banner",
    "I have nothing to prove to you.\n- Carol Danvers",
    "Part of the journey is the end.\n- Tony Stark",
    "I'm not a queen or a monster. I'm the goddess of death.\n- Hela",
    "We don't get to choose our time. Death is what gives life meaning.\n- Natasha Romanoff",
    "Sometimes you gotta run before you can walk.\n- Tony Stark",
    "You can't save the world alone.\n- Batman",
    "I'm a huge fan of the way you lose control and turn into an enormous green rage monster.\n- Tony Stark",
    "I can't control their fear, only my own.\n- Wanda Maximoff",
    "In my culture, death is not the end.\n- T'Challa",
    "Dread it. Run from it. Destiny arrives all the same.\n- Thanos",
    "I don't judge people on their worst mistakes.\n- Natasha Romanoff",
    "The sun will shine on us again.\n- Thor",
    "Whatever it takes.\n- Steve Rogers",
    "We're the Avengers. We can bust arms dealers all the live long day, but that up there? That's... that's the endgame.\n- Tony Stark",
    "We're not a team, we're a time bomb.\n- Tony Stark",
    "I can't save the world, not like you guys can.\n- Clint Barton",
    "I'm going to need a rain check on that dance.\n- Steve Rogers",
    "I keep telling everybody they should move on. Some do, but not us.\n- Steve Rogers",
    "The hardest choices require the strongest wills.\n- Thanos",
    "The only thing permanent in life is impermanence.\n- Thor",
    "I'm just a messenger with a message. Your choice is simple: join us and live in peace or pursue your present course and face obliteration.\n- Vision",
    "A thing isn't beautiful because it lasts.\n- Vision",
    "The truth is... I am Iron Man.\n- Tony Stark",
    "Avengers... assemble!\n- Captain America",
    "Avengers, time to work for a living!\n- Tony Stark",
    "Sometimes the best weapon in your arsenal is just patience.\n- Hawkeye",
    "I can do this all day.\n- Steve Rogers",
    "A thing isn't beautiful because it lasts.\n- Vision",
    "The truth is... I am Iron Man.\n- Tony Stark",
    "I can't control their fear, only my own.\n- Wanda Maximoff",
    "In my culture, death is not the end.\n- T'Challa",
    "I'm with you 'til the end of the line.\n- Steve Rogers",
    "I have nothing to prove to you.\n- Carol Danvers",
    "We don't get to choose our time. Death is what gives life meaning.\n- Natasha Romanoff",
    "I am Groot.\n- Groot",
    "I'm just a guy who cares too much.\n- Vision",
    "Genius, billionaire, playboy, philanthropist.\n- Tony Stark",
    "I'm not a hero. I'm a high-functioning disaster.\n- Tony Stark",
    "The sun will shine on us again.\n- Thor",
    "I'm sorry, did I step on your moment?\n- Tony Stark",
    "Heroes are made by the path they choose, not the powers they are graced with.\n- Tony Stark",
    "I'm always angry.\n- Bruce Banner",
    "I can't save the world, not like you guys can.\n- Clint Barton",
    "I had strings, but now I'm free.\n- Ultron",
    "Be yourself; everyone else is already taken.\n- Oscar Wilde",
    "I'm just a kid from Brooklyn.\n- Steve Rogers",
    "I'm not a queen or a monster. I'm the goddess of death.\n- Hela",
    "We're not a team, we're a time bomb.\n- Tony Stark",
    "I'm not a hero. I'm a high-functioning sociopath.\n- Tony Stark",
    "I keep telling everybody they should move on. Some do, but not us.\n- Steve Rogers",
    "I'm always looking for trouble.\n- Tony Stark",
    "Dread it. Run from it. Destiny arrives all the same.\n- Thanos",
    "The only way to do great work is to love what you do.\n- Steve Jobs",
    "We're the Avengers. We can bust arms dealers all the live long day, but that up there? That's... that's the endgame.\n- Tony Stark",
    "You can't save the world alone.\n- Batman",
    "I could do this all day.\n- Steve Rogers",
    "I'm going to need a rain check on that dance.\n- Steve Rogers",
    "That's my secret, Cap. I'm always angry.\n- Bruce Banner",
    "I don't judge people on their worst mistakes.\n- Natasha Romanoff",
    "The hardest choices require the strongest wills.\n- Thanos",
    "The only thing permanent in life is impermanence.\n- Thor",
    "I am burdened with glorious purpose.\n- Loki",
    "Believe you can and you're halfway there.\n- Theodore Roosevelt",
    "It's not about how much we lost, it's about how much we have left.\n- Tony Stark",
    "Part of the journey is the end.\n- Tony Stark",
    "I don't see how that's a party.\n- Clint Barton",
    "I'm a huge fan of the way you lose control and turn into an enormous green rage monster.\n- Tony Stark",
    "I keep telling everybody they should move on. Some do, but not us.\n- Steve Rogers",
    "I don't judge people on their worst mistakes.\n- Natasha Romanoff",
    "We're not a team, we're a time bomb.\n- Tony Stark",
    "I'm always looking for trouble.\n- Tony Stark",
    "I'm going to need a rain check on that dance.\n- Steve Rogers"
  ];
  final Random random = Random();
  int quoteIndex = 0;
  int currentIndex = 0;

  final GlobalKey _globalKey = GlobalKey();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _isMounted = true;
    _loadQuotes();
    _loadPhotos();
  }

  @override
  void dispose() {
    _isMounted = false;

    super.dispose();
  }

  void _loadQuotes() {
    avengersQuotes = List.from(avengersQuotes)..shuffle();
  }

  void changePhoto() {
    setState(() {
      currentIndex = random.nextInt(avengersURLs.length);
    });
  }

  void changeQuote() {
    setState(() {
      quoteIndex = random.nextInt(avengersQuotes.length);
    });
  }

  void updateRandomValues() {
    currentIndex = random.nextInt(avengersURLs.length);
    avengersQuotes.shuffle();
    quoteIndex = random.nextInt(avengersQuotes.length);
  }

  Future<void> _loadPhotos() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      try {
        int pageSize = 250; // Number of photos to load per page
        String? pageToken = avengersURLs.isNotEmpty ? avengersURLs.last : null;
        ListResult result = await avengersRef.list(ListOptions(
          maxResults: pageSize,
          pageToken: pageToken,
        ));

        for (Reference ref in result.items) {
          String downloadURL = await ref.getDownloadURL();
          if (_isMounted) {
            setState(() {
              avengersURLs.add(downloadURL);
            });
          }
        }

        List<String> shuffledURLs = avengersURLs.toList();
        shuffledURLs.shuffle();
        // avengersURLs = shuffledURLs.toSet();
        // ignore: empty_catches
      } catch (e) {}

      if (_isMounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> captureAndShareScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/Image.png';
        final file = File(filePath);

        await file.writeAsBytes(pngBytes);

        await Future.microtask(() {
          Share.shareFiles([filePath], text: avengersQuotes[quoteIndex]);
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  TextSpan buildTextSpan() {
    final String quote = avengersQuotes[quoteIndex];
    final List<String> quoteParts = quote.split('\n');
    final String quoteText = quoteParts[0];
    final String writerName = quoteParts[1];

    return TextSpan(
      text: quoteText,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      children: [
        TextSpan(
          text: writerName,
          style: GoogleFonts.kanit(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    return Scaffold(
      appBar: null,
      backgroundColor: backgroundColour,
      body: Center(
        child: RepaintBoundary(
          key: _globalKey,
          child: Swiper(
            loop: false,
            itemCount: avengersURLs.length,
            onIndexChanged: (index) {
              setState(() {
                updateRandomValues();
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: avengersURLs[index],
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.2,
                    bottom: MediaQuery.of(context).size.height * 0.2,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: GestureDetector(
                          onTap: changeQuote,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5,
                                  sigmaY: 5,
                                ), // Adjust the sigma values for desired blur strength
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Colors.white, Colors.black]),
                                    color: Colors.white.withOpacity(0.65),
                                    border: Border.all(
                                      width: 0,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text.rich(
                                      buildTextSpan(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFE5163),
        onPressed: captureAndShareScreenshot,
        child: const Icon(Icons.share),
      ),
    );
  }
}

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Movies Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class MoviesPage extends StatefulWidget {
  const MoviesPage({Key? key}) : super(key: key);

  @override
  MoviesPageState createState() => MoviesPageState();
}

class MoviesPageState extends State<MoviesPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await moviesRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        moviesRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Movies',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < moviesRefs.length) {
                              final fy = moviesRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Hindi Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class HindiPage extends StatefulWidget {
  const HindiPage({Key? key}) : super(key: key);

  @override
  HindiPageState createState() => HindiPageState();
}

class HindiPageState extends State<HindiPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await hindiRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        hindiRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Hindi',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < hindiRefs.length) {
                              final fy = hindiRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Best Wishes              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class WishesPage extends StatefulWidget {
  const WishesPage({Key? key}) : super(key: key);

  @override
  WishesPageState createState() => WishesPageState();
}

class WishesPageState extends State<WishesPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await bestWishesRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        bestwishesRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Best Wishes',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < bestwishesRefs.length) {
                              final fy = bestwishesRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Friendship Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class FriendshipPage extends StatefulWidget {
  const FriendshipPage({Key? key}) : super(key: key);

  @override
  FriendshipPageState createState() => FriendshipPageState();
}

class FriendshipPageState extends State<FriendshipPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await friendshipRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        friendshipRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Friendship',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < friendshipRefs.length) {
                              final fy = friendshipRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Success Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class SuccessPage extends StatefulWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  SuccessPageState createState() => SuccessPageState();
}

class SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await successRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        successRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Success',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < successRefs.length) {
                              final fy = successRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Motivational Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class MotivationalPage extends StatefulWidget {
  const MotivationalPage({Key? key}) : super(key: key);

  @override
  MotivationalPageState createState() => MotivationalPageState();
}

class MotivationalPageState extends State<MotivationalPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await motivationalRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        motivationalRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Motivational',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < motivationalRefs.length) {
                              final fy = motivationalRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Fitness Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class FitnessPage extends StatefulWidget {
  const FitnessPage({Key? key}) : super(key: key);

  @override
  FitnessPageState createState() => FitnessPageState();
}

class FitnessPageState extends State<FitnessPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await fitnessRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        fitnessRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Fitness',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < fitnessRefs.length) {
                              final fy = fitnessRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Nature Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class NaturePage extends StatefulWidget {
  const NaturePage({Key? key}) : super(key: key);

  @override
  NaturePageState createState() => NaturePageState();
}

class NaturePageState extends State<NaturePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await natureRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        natureRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Nature',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < natureRefs.length) {
                              final fy = natureRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Courage Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class CouragePage extends StatefulWidget {
  const CouragePage({Key? key}) : super(key: key);

  @override
  CouragePageState createState() => CouragePageState();
}

class CouragePageState extends State<CouragePage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await courageRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        courageRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Courage',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < courageRefs.length) {
                              final fy = courageRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Business Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class BusinessPage extends StatefulWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  BusinessPageState createState() => BusinessPageState();
}

class BusinessPageState extends State<BusinessPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await businessRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        businessRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;

    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Business',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < businessRefs.length) {
                              final fy = businessRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Power Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================
class PowerPage extends StatefulWidget {
  const PowerPage({Key? key}) : super(key: key);

  @override
  PowerPageState createState() => PowerPageState();
}

class PowerPageState extends State<PowerPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await powerRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        powerRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;

    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        elevation: 8,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: backgroundColour,
        title: Text(
          'Power',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < powerRefs.length) {
                              final fy = powerRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

//================================================================================================================================================================
//================================================================================================================================================================
//===========================================            Wisdom Page              ==================================================================
//================================================================================================================================================================
//================================================================================================================================================================

class WisdomPage extends StatefulWidget {
  const WisdomPage({Key? key}) : super(key: key);

  @override
  WisdomPageState createState() => WisdomPageState();
}

class WisdomPageState extends State<WisdomPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    _tabController = TabController(length: 2, vsync: this);
    shuffleImages();
  }

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> shuffleImages() async {
    final ListResult result = await wisdomRef.listAll();
    final List<Reference> shuffledrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        wisdomRefs = shuffledrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      bottomNavigationBar: _banner == null
          ? const SizedBox(
              height: 0,
            )
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        elevation: 8,
        backgroundColor: backgroundColour,
        title: Text(
          'Wisdom',
          style: GoogleFonts.kanit(
            color: secondaryColour,
            fontSize: 22,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                backgroundColor: backgroundColour,
                color: secondaryColour,
                onRefresh: refreshImages,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index % 10 == 0 && index > 0) {
                            return _buildNativeAdWidget();
                          } else {
                            final fyIndex = index - (index ~/ 10);
                            if (fyIndex < wisdomRefs.length) {
                              final fy = wisdomRefs[fyIndex];
                              return FutureBuilder<String>(
                                future: fy.getDownloadURL(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    final heroTag = 'image_hero_$imageUrl';

    return Hero(
      tag: heroTag,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(imageUrl, heroTag);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: primaryColour.withOpacity(0.2),
                  blurRadius: 10,
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
                placeholder: (context, url) => Components.buildPlaceholder(),
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
  }

  void _showFullScreenImage(String imageUrl, String heroTag) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;

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
                // onVerticalDragStart: (details) {
                //   if (details.! > 0) {
                //     Navigator.of(context).pop();
                //   }
                // },
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
                              ();
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

class NativeAdWidget extends StatelessWidget {
  final NativeAd nativeAd;

  const NativeAdWidget(this.nativeAd, {super.key});

  @override
  Widget build(BuildContext context) {
    // Customize the appearance of the native ad
    return Container(
      margin: const EdgeInsets.all(16),
      child: AdWidget(ad: nativeAd),
    );
  }
}
