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

class CategoryPage extends StatefulWidget {
  final String reference;
  const CategoryPage({required this.reference, Key? key}) : super(key: key);

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  late Reference categoryRef;

  List<Reference> categoryRefs = [];
  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _loadFavoriteImages();
    loadNativeAd();
    categoryRef = storage.ref().child(widget.reference);
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
    final ListResult result1 = await categoryRef.listAll();
    final List<Reference> shuffledcategoryRefs = result1.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        categoryRefs = shuffledcategoryRefs;
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
                            if (fyIndex < categoryRefs.length) {
                              final fy = categoryRefs[fyIndex];
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
