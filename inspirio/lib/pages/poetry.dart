import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:inspirio/components/widgets.dart';
import 'package:inspirio/pages/pages.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inspirio/pages/poetry_pages.dart';
import 'package:inspirio/services/admob_services.dart';
// import 'package:inspirio/services/ad_provider.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
import 'package:share/share.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final Reference poetryRef = storage.ref().child('poetry');

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

final List<String> poeters = [
  '   William     Shakespeare',
  'Rabindran-ath Tagore',
  'Gulzar        ',
  'Emily  Dickinson',
  'Mirza Ghalib',
  'Robert Frost',
  'Pablo Neruda',
];

final List<String> poetersImages = [
  'gs://inspirio-hyperlink.appspot.com/poetersimg/william.jpeg',
  'gs://inspirio-hyperlink.appspot.com/poetersimg/rabindernath.jpg',
  'gs://inspirio-hyperlink.appspot.com/poetersimg/gulzar.jpg',
  'gs://inspirio-hyperlink.appspot.com/poetersimg/emily.webp',
  'gs://inspirio-hyperlink.appspot.com/poetersimg/mirza.jpg',
  'gs://inspirio-hyperlink.appspot.com/poetersimg/robert.jpg',
  'gs://inspirio-hyperlink.appspot.com/poetersimg/pablo.jpeg'
];

class PoetryPage extends StatefulWidget {
  const PoetryPage({Key? key}) : super(key: key);

  @override
  PoetryPageState createState() => PoetryPageState();
}

class PoetryPageState extends State<PoetryPage>
    with SingleTickerProviderStateMixin {
  List<Reference> poetryRefs = [];
  late SharedPreferences _prefs;
  List<String> favoriteImages = [];

  // late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadFavoriteImages();
    _createBannerAd();
    _createInterstitialAd();
    loadNativeAd();
    shuffleImages();
  }

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  BannerAd? _banner;
  InterstitialAd? _interstitialAd;
  void _createBannerAd() {
    _banner = BannerAd(
      size: AdSize.fullBanner,
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

  Future<void> shuffleImages() async {
    final ListResult result = await poetryRef.listAll();
    final List<Reference> shuffledpoetryrefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        poetryRefs = shuffledpoetryrefs;
      });
    }
  }

  Future<void> refreshImages() async {
    await shuffleImages();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
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
        // centerTitle: true,
        backgroundColor: backgroundColour,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          "Poetry",
          style: GoogleFonts.kanit(
            fontSize: 22,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      key: _scaffoldKey,
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: AnimationLimiter(
          child: Column(
            children: [
              _buildPoetersTab(),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.04,
                  ),
                  Expanded(
                    child: Text('Recommended',
                        style: GoogleFonts.kanit(
                            fontSize: 18, color: primaryColour)),
                  ),
                  const Divider(
                    thickness: 1.0,
                  )
                ],
              ),
              _buildPoetryPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoetersTab() {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.17,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: poetersImages.length,
        itemBuilder: (BuildContext context, int index) {
          final category = poeters[index];

          Future<String> getImageUrl() async {
            final Reference ref =
                FirebaseStorage.instance.refFromURL(poetersImages[index]);
            final String downloadURL = await ref.getDownloadURL();
            return downloadURL;
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          height: 75,
                          width: 75,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 3.5,
                                color: primaryColour.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: FutureBuilder(
                            future: getImageUrl(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox();
                              }
                              if (snapshot.hasError) {
                                return const Text('Error loading image');
                              }
                              final imageUrl = snapshot.data.toString();
                              return Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(imageUrl),
                                  ),
                                  border: Border.all(
                                      width: 3.5,
                                      color: primaryColour.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              );
                            },
                          ),
                        ),
                        onTap: () {
                          _showInterstitialAd();
                          _navigateToCategoryPage(category);
                        },
                      ),
                      const SizedBox(height: 3.5),
                      Text(
                        poeters[index].substring(0, poeters[index].length ~/ 2),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        poeters[index].substring(poeters[index].length ~/ 2),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPoetryPage() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: RefreshIndicator(
        backgroundColor: backgroundColour,
        color: primaryColour,
        onRefresh: refreshImages,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index % 10 == 0 && index > 0) {
                    return _buildNativeAdWidget();
                  } else {
                    final fyIndex = index - (index ~/ 10);
                    if (fyIndex < poetryRefs.length) {
                      final fy = poetryRefs[fyIndex];
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
                          Container(
                            decoration: BoxDecoration(
                                color: primaryColour, shape: BoxShape.circle),
                            child: IconButton(
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
                              icon: Icon(
                                favoriteImages.contains(imageUrl)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: secondaryColour,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: primaryColour, shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                _showInterstitialAd();
                                savetoGallery(context);
                              },
                              icon: Icon(
                                Iconsax.arrow_down,
                                color: secondaryColour,
                              ),
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
                            // heroTag: null,
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

void _navigateToCategoryPage(String category) {
  switch (category) {
    case '   William     Shakespeare':
      Get.to(() => const ShakespearePage(), transition: Transition.native);
      break;
    case 'Rabindran-ath Tagore':
      Get.to(() => const RabindernathPage(), transition: Transition.native);
      break;
    case 'Gulzar        ':
      Get.to(() => const GulzarPage(), transition: Transition.native);
      break;
    case 'Emily  Dickinson':
      Get.to(() => const EmilyPage(), transition: Transition.native);
      break;
    case 'Mirza Ghalib':
      Get.to(() => const MirzaPage(), transition: Transition.native);
      break;
    case 'Robert Frost':
      Get.to(() => const RobertPage(), transition: Transition.native);
      break;
    case 'Pablo Neruda':
      Get.to(() => const PabloPage(), transition: Transition.native);
      break;

    default:
      break;
  }
}
