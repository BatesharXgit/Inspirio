import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:inspirio/components/widgets.dart';
import 'package:inspirio/creator/creator.dart';
import 'package:inspirio/creator/creator_photo.dart';
import 'package:inspirio/services/admob_services.dart';
import 'package:path_provider/path_provider.dart';
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

class InspirioHome extends ConsumerStatefulWidget {
  const InspirioHome({super.key});
  // static const numOfTabs = 2;

  // Future<void> initializeData() async {
  //   final state = _InspirioHomeState();
  //   await state.refreshForYouImages();
  // }

  @override
  ConsumerState<InspirioHome> createState() => _InspirioHomeState();
}

class _InspirioHomeState extends ConsumerState<InspirioHome>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
    _createInterstitialAd();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabSelection);
    refreshForYouImages();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          refreshForYouImages();
          break;
        case 1:
          refreshPopularImages();
          break;
        case 2:
          refreshHindiImages();
          break;
        case 3:
          refreshMorningImages();
          break;
        case 4:
          refreshMotivationalImages();
          break;
        case 5:
          refreshAttitudeImages();
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabController.removeListener(_handleTabSelection);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  InterstitialAd? _interstitialAd;

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
          Future.delayed(const Duration(minutes: 1), () {
            _createInterstitialAd();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          Future.delayed(const Duration(minutes: 1), () {
            _createInterstitialAd();
          });
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
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

  Map<Reference, String> cachedDownloadUrls = {};

  Future<void> refreshForYouImages() async {
    final ListResult result = await foryouRef.listAll();
    final shuffledRefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        foryouRefs = shuffledRefs;
        cachedDownloadUrls.clear();
      });
    }
  }

  Future<void> refreshPopularImages() async {
    final ListResult result = await popularRef.listAll();
    final shuffledRefs = result.items.toList()..shuffle();

    if (mounted) {
      setState(() {
        popularRefs = shuffledRefs;
        cachedDownloadUrls.clear();
      });
    }
  }

  Future<void> refreshHindiImages() async {
    final ListResult result = await hindiRef.listAll();
    final shuffledRefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        hindiRefs = shuffledRefs;
      });
    }
  }

  Future<void> refreshMorningImages() async {
    final ListResult result = await morningRef.listAll();
    final shuffledRefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        morningRefs = shuffledRefs;
      });
    }
  }

  Future<void> refreshMotivationalImages() async {
    final ListResult result = await motivationalRef.listAll();
    final shuffledRefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        motivationalRefs = shuffledRefs;
      });
    }
  }

  Future<void> refreshAttitudeImages() async {
    final ListResult result = await attitudeRef.listAll();
    final shuffledRefs = result.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        attitudeRefs = shuffledRefs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: null,
        backgroundColor: backgroundColour,
        body: FutureBuilder<ListResult>(
          future: foryouRef.listAll(),
          builder: (context, snapshot) {
            return SafeArea(
              child: NestedScrollView(
                controller: ScrollController(),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: MediaQuery.of(context).size.height * 0.1,
                      floating: true,
                      pinned: false,
                      elevation: 0,
                      backgroundColor: backgroundColour,
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: false,
                        title: null,
                        background: Container(
                          color: backgroundColour,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Inspirio',
                                  style: GoogleFonts.cookie(
                                    // fontFamily: 'Anurati',
                                    color: secondaryColour,
                                    fontSize: 44,
                                    // fontWeight: FontWeight.bold,
                                  ),
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
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: backgroundColour,
          onPressed: () {
            _showInterstitialAd();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InspirioCreator(),
              ),
            );
          },
          heroTag: 3,
          icon: Icon(
            Icons.create_outlined,
            color: secondaryColour,
          ),
          label: Text(
            'Create',
            style: TextStyle(color: secondaryColour),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Container(
      height: 100,
      color: backgroundColour,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
        child: TabBar(
          dividerColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          physics: const ClampingScrollPhysics(),
          indicatorPadding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
          controller: _tabController,
          indicatorColor: secondaryColour,
          indicator: BoxDecoration(
            color: secondaryColour,
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
                border: Border.all(width: 2.0, color: secondaryColour),
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
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
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
    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final reference = foryouRefs[index];
                final cachedUrl = cachedDownloadUrls[reference];
                if (cachedUrl != null) {
                  return _buildImageWidget(cachedUrl);
                } else {
                  return FutureBuilder<String>(
                    future: reference.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        final downloadUrl = snapshot.data!;
                        cachedDownloadUrls[reference] = downloadUrl;
                        return _buildImageWidget(downloadUrl);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
              childCount: foryouRefs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTab() {
    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final reference = popularRefs[index];
                final cachedUrl = cachedDownloadUrls[reference];
                if (cachedUrl != null) {
                  return _buildImageWidget(cachedUrl);
                } else {
                  return FutureBuilder<String>(
                    future: reference.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        final downloadUrl = snapshot.data!;
                        cachedDownloadUrls[reference] = downloadUrl;
                        return _buildImageWidget(downloadUrl);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
              childCount: popularRefs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHindiTab() {
    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final reference = hindiRefs[index];
                final cachedUrl = cachedDownloadUrls[reference];
                if (cachedUrl != null) {
                  return _buildImageWidget(cachedUrl);
                } else {
                  return FutureBuilder<String>(
                    future: reference.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        final downloadUrl = snapshot.data!;
                        cachedDownloadUrls[reference] = downloadUrl;
                        return _buildImageWidget(downloadUrl);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
              childCount: hindiRefs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningTab() {
    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final reference = morningRefs[index];
                final cachedUrl = cachedDownloadUrls[reference];
                if (cachedUrl != null) {
                  return _buildImageWidget(cachedUrl);
                } else {
                  return FutureBuilder<String>(
                    future: reference.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        final downloadUrl = snapshot.data!;
                        cachedDownloadUrls[reference] = downloadUrl;
                        return _buildImageWidget(downloadUrl);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
              childCount: morningRefs.length,
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
    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final reference = motivationalRefs[index];
                final cachedUrl = cachedDownloadUrls[reference];
                if (cachedUrl != null) {
                  return _buildImageWidget(cachedUrl);
                } else {
                  return FutureBuilder<String>(
                    future: reference.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        final downloadUrl = snapshot.data!;
                        cachedDownloadUrls[reference] = downloadUrl;
                        return _buildImageWidget(downloadUrl);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
              childCount: motivationalRefs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttitudeTab() {
    return RefreshIndicator(
      backgroundColor: Theme.of(context).colorScheme.background,
      color: Theme.of(context).colorScheme.primary,
      onRefresh: refreshForYouImages,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final reference = attitudeRefs[index];
                final cachedUrl = cachedDownloadUrls[reference];
                if (cachedUrl != null) {
                  return _buildImageWidget(cachedUrl);
                } else {
                  return FutureBuilder<String>(
                    future: reference.getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Components.buildPlaceholder();
                      } else if (snapshot.hasError) {
                        return Components.buildErrorWidget();
                      } else if (snapshot.hasData) {
                        final downloadUrl = snapshot.data!;
                        cachedDownloadUrls[reference] = downloadUrl;
                        return _buildImageWidget(downloadUrl);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
              childCount: attitudeRefs.length,
            ),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
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

  void _showFullScreenImage(
    String imageUrl,
    String heroTag,
  ) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    final heroTag = 'image_hero_$imageUrl';

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
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FloatingActionButton(
                                backgroundColor: backgroundColour,
                                heroTag: 2,
                                onPressed: () {
                                  _showInterstitialAd();
                                  savetoGallery(context);
                                },
                                child: Icon(
                                  Iconsax.arrow_down,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FloatingActionButton.extended(
                                backgroundColor: backgroundColour,
                                onPressed: () {
                                  _showInterstitialAd();
                                  Navigator.pop(context);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => InspirioEditor(
                                        imageUrl: imageUrl,
                                      ),
                                    ),
                                  );
                                },
                                label: Text(
                                  'Edit',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                icon: Icon(
                                  Iconsax.edit,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FloatingActionButton.extended(
                                backgroundColor: backgroundColour,
                                onPressed: () {
                                  _showInterstitialAd();
                                  shareQuotes(imageUrl);
                                },
                                heroTag: 3,
                                icon: Icon(
                                  Iconsax.share,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                label: Text(
                                  'Share',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                            ],
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
