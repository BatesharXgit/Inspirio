import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspirio/components/widgets.dart';
import 'package:inspirio/services/admob_services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'package:share/share.dart';

late TabController _tabController;
bool isGalleryImage = false;

Future<void> shareCustomQuotes() async {
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

      await Share.shareFiles([filePath],
          text:
              "Inspirio - https://play.google.com/store/apps/details?id=com.application.inspirio&pcampaignid=web_share");
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
        if (kDebugMode) {
          print('Screenshot saved to gallery.');
        }

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
      } else {
        if (kDebugMode) {
          print('Failed to save screenshot to gallery.');
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error: $e');
    }
  }
}

final Reference backgroundRef =
    FirebaseStorage.instance.ref().child('creator/backgrounds');
final Reference devotionalRef =
    FirebaseStorage.instance.ref().child('creator/devotional');
final Reference floralRef =
    FirebaseStorage.instance.ref().child('creator/floral');
final Reference neonRef = FirebaseStorage.instance.ref().child('creator/neons');
final Reference coloursRef =
    FirebaseStorage.instance.ref().child('creator/colors');

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

List<Reference> backgroundRefs = [];
List<Reference> devotionalRefs = [];
List<Reference> floralRefs = [];
List<Reference> neonRefs = [];
List<Reference> coloursRefs = [];

final List<String> data = [
  "Backgrounds",
  "Devotional",
  "Floral",
  "Neons",
  "Colours",
  "Text Style",
  "Text Colour",
];
String? selectedImageUrl;
String? selectedFontFamily;

Color selectedColor = Colors.white;
Color selectedWriterColor = Colors.white;

final GlobalKey _globalKey = GlobalKey();

class InspirioCreator extends StatefulWidget {
  const InspirioCreator({Key? key}) : super(key: key);

  @override
  State<InspirioCreator> createState() => InspirioCreatorState();
}

class InspirioCreatorState extends State<InspirioCreator>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<String?> selectedImageUrlNotifier =
      ValueNotifier<String?>(null);
  bool _isBackPressed = false;
  File? pickedImageFile;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _tabController = TabController(length: data.length, vsync: this);
    loadbackgroundImages();
    loaddevotionalImages();
    loadfloralImages();
    loadneonImages();
    loadcoloursImages();
    // AdProvider adProvider = Provider.of<AdProvider>(context, listen: false);
    // adProvider.initializeFullPageAds();
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

  Future<void> loadbackgroundImages() async {
    final ListResult result = await backgroundRef.listAll();
    final List<Reference> shuffledbackgroundrefs = result.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        backgroundRefs = shuffledbackgroundrefs;
      });
    }
  }

  Future<void> loaddevotionalImages() async {
    final ListResult result1 = await devotionalRef.listAll();
    final List<Reference> shuffleddevotionalrefs = result1.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        devotionalRefs = shuffleddevotionalrefs;
      });
    }
  }

  Future<void> loadneonImages() async {
    final ListResult result2 = await neonRef.listAll();
    final List<Reference> shuffledneonrefs = result2.items.toList()..shuffle();
    if (mounted) {
      setState(() {
        neonRefs = shuffledneonrefs;
      });
    }
  }

  Future<void> loadfloralImages() async {
    final ListResult result3 = await floralRef.listAll();
    final List<Reference> shuffledfloralrefs = result3.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        floralRefs = shuffledfloralrefs;
      });
    }
  }

  Future<void> loadcoloursImages() async {
    final ListResult result4 = await coloursRef.listAll();
    final List<Reference> shuffledcoloursrefs = result4.items.toList()
      ..shuffle();
    if (mounted) {
      setState(() {
        coloursRefs = shuffledcoloursrefs;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addImageToStack(String imageUrl) {
    pickedImageFile = null;
    // pickedFile = null;
    isGalleryImage = false;
    selectedImageUrlNotifier.value = imageUrl;
  }

  // bool isGalleryImage = false;

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isGalleryImage = true;
        selectedImageUrl = null;
        pickedImageFile = File(pickedFile.path);
      });
    }
  }

  bool buttonVisible = false;

  void _isButtonsVisible() {
    setState(() {
      buttonVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: null,
        backgroundColor: backgroundColour,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.89,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Creator',
                          style: GoogleFonts.orbitron(
                              fontSize: 22,
                              color: secondaryColour,
                              fontWeight: FontWeight.w800),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _isButtonsVisible();
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                width: 50,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: primaryColour,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Icon(
                                  Icons.done_outline,
                                  color: secondaryColour,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Visibility(
                              visible: buttonVisible,
                              child: AnimationLimiter(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      opacity: buttonVisible ? 1.0 : 0.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _showInterstitialAd();
                                          savetoGallery(context);
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: primaryColour,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: Icon(
                                            Icons.download_outlined,
                                            color: secondaryColour,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                    AnimatedOpacity(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      opacity: buttonVisible ? 1.0 : 0.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _showInterstitialAd();
                                          shareCustomQuotes();
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: primaryColour,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Share',
                                              style: GoogleFonts.kanit(
                                                color: secondaryColour,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 3.0,
                  ),
                  ImageStack(
                    selectedImageUrlNotifier: selectedImageUrlNotifier,
                    onImageSelected: _addImageToStack,
                    pickedImageFile: pickedImageFile,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Row(
                      children: [
                        FloatingActionButton.small(
                          onPressed: () {
                            pickImage();
                          },
                          backgroundColor: primaryColour,
                          heroTag: null,
                          child: Icon(
                            Iconsax.image,
                            color: secondaryColour,
                          ),
                        ),
                        Expanded(child: _buildTabBar()),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.14,
                    child: _buildTabViews(),
                  ),
                ],
              ),
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _banner != null
            ? SizedBox(
                height: 52,
                child: AdWidget(ad: _banner!),
              )
            : const SizedBox(
                height: 0,
              ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    if (_isBackPressed) {
      return Future.value(true);
    } else {
      _showSnackBar();
      _isBackPressed = true;
      Future.delayed(const Duration(seconds: 2), () {
        _isBackPressed = false;
      });
      return Future.value(false);
    }
  }

  void _showSnackBar() {
    const snackBar = SnackBar(
      backgroundColor: Color(0xFF000000),
      content: Text(
        'Press back again to exit',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildTabBar() {
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
      child: TabBar(
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        physics: const BouncingScrollPhysics(),
        indicatorPadding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        controller: _tabController,
        indicatorColor: secondaryColour,
        indicator: BoxDecoration(
          color: secondaryColour,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: primaryColour,
        unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
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
    );
  }

  Widget _buildTabViews() {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildBackgroundTab(),
        _buildDevotionalTab(),
        _buildFloralTab(),
        _buildNeonsTab(),
        _buildColoursTab(),
        Center(
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: 1,
            children: [
              'Roboto',
              'Dancing Script',
              'Caveat',
              'Shadows Into Light',
              'Open Sans',
              'Kalam',
              'Permanent Marker',
              'Great Vibes',
              'Kaushan Script',
              'Raleway',
              'Poppins',
              'Source Sans Pro',
              'Nunito',
              'Oswald',
              'Playfair Display',
              'Quicksand',
              'Ubuntu',
              'Exo',
              'Rubik',
              'Roboto Condensed',
              'Pacifico',
              'Josefin Sans',
              'Merriweather',
              'PT Sans',
              'Cabin',
              'Titillium Web',
              'Arimo',
              'Noto Sans',
              'Fira Sans',
              'Archivo',
              'Maven Pro',
              'Karla',
              'Prompt',
              'Hind',
              'DM Sans',
              'Yantramanav',
              'Abel',
              'Cormorant',
              'Rajdhani',
              'Saira',
              'Lora',
              'Varela Round',
            ].map((String font) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFontFamily = font;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: selectedFontFamily == font
                            ? primaryColour.withOpacity(0.5)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        font,
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: font,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColour,
                elevation: 10,
                shadowColor: primaryColour,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: backgroundColour,
                      title: Text(
                        'Pick a color',
                        style: GoogleFonts.kanit(color: primaryColour),
                      ),
                      content: SingleChildScrollView(
                        child: MaterialColorPicker(
                          alignment: WrapAlignment.spaceEvenly,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          selectedColor: selectedColor,
                          onColorChange: (color) {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          onMainColorChange: (color) {
                            setState(() {
                              selectedColor = color as Color;
                            });
                          },
                        ),
                      ),
                      actions: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.done,
                            color: primaryColour,
                          ),
                          color: primaryColour,
                        )
                      ],
                    );
                  },
                );
              },
              child: const Text('Pick a color for Quote'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColour,
                elevation: 10,
                shadowColor: primaryColour,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: backgroundColour,
                      title: Text(
                        'Pick a color',
                        style: GoogleFonts.kanit(color: primaryColour),
                      ),
                      content: SingleChildScrollView(
                        child: MaterialColorPicker(
                          alignment: WrapAlignment.spaceEvenly,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          selectedColor: selectedWriterColor,
                          onColorChange: (colorWriter) {
                            setState(() {
                              selectedWriterColor = colorWriter;
                            });
                          },
                          onMainColorChange: (colorWriter) {
                            setState(() {
                              selectedWriterColor = colorWriter as Color;
                            });
                          },
                        ),
                      ),
                      actions: <Widget>[
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.done),
                          color: primaryColour,
                        )
                      ],
                    );
                  },
                );
              },
              child: const Text('Pick a color for Writer'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackgroundTab() {
    return RefreshIndicator(
      onRefresh: loadbackgroundImages,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisExtent: 100,
          mainAxisSpacing: 5,
          childAspectRatio: 1,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: backgroundRefs.length,
        itemBuilder: (context, index) {
          final mRef = backgroundRefs[index];
          return FutureBuilder<String>(
            future: mRef.getDownloadURL(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Components.buildPlaceholder();
              } else if (snapshot.hasError) {
                return Container(
                  color: Colors.red,
                  child: const Icon(Icons.error),
                );
              } else if (snapshot.hasData) {
                return _buildImageWidget(snapshot.data!);
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDevotionalTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 100,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: devotionalRefs.length,
      itemBuilder: (context, index) {
        final devRef = devotionalRefs[index];
        return FutureBuilder<String>(
          future: devRef.getDownloadURL(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Components.buildPlaceholder();
            } else if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: const Icon(Icons.error),
              );
            } else if (snapshot.hasData) {
              return _buildImageWidget(snapshot.data!);
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Widget _buildFloralTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 100,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: floralRefs.length,
      itemBuilder: (context, index) {
        final fRef = floralRefs[index];
        return FutureBuilder<String>(
          future: fRef.getDownloadURL(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Components.buildPlaceholder();
            } else if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: const Icon(Icons.error),
              );
            } else if (snapshot.hasData) {
              return _buildImageWidget(snapshot.data!);
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Widget _buildNeonsTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 100,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: neonRefs.length,
      itemBuilder: (context, index) {
        final neoRef = neonRefs[index];
        return FutureBuilder<String>(
          future: neoRef.getDownloadURL(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Components.buildPlaceholder();
            } else if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: const Icon(Icons.error),
              );
            } else if (snapshot.hasData) {
              return _buildImageWidget(snapshot.data!);
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Widget _buildColoursTab() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 100,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: coloursRefs.length,
      itemBuilder: (context, index) {
        final coloursRef = coloursRefs[index];
        return FutureBuilder<String>(
          future: coloursRef.getDownloadURL(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Components.buildPlaceholder();
            } else if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: const Icon(Icons.error),
              );
            } else if (snapshot.hasData) {
              return _buildImageWidget(snapshot.data!);
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return InkWell(
      onTap: () {
        _addImageToStack(imageUrl);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          fadeInDuration: const Duration(milliseconds: 100),
          fadeOutDuration: const Duration(milliseconds: 100),
          imageUrl: imageUrl,
          placeholder: (context, url) => Components.buildPlaceholder(),
          errorWidget: (context, url, error) => Container(
            color: Colors.red,
            child: const Icon(Icons.error),
          ),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          colorBlendMode: BlendMode.saturation,
          cacheManager: DefaultCacheManager(),
        ),
      ),
    );
  }
}

class ImageStack extends StatefulWidget {
  final ValueNotifier<String?> selectedImageUrlNotifier;
  final Function(String) onImageSelected;
  final File? pickedImageFile;

  const ImageStack({
    Key? key,
    required this.selectedImageUrlNotifier,
    required this.onImageSelected,
    this.pickedImageFile,
  }) : super(key: key);

  @override
  ImageStackState createState() => ImageStackState();
}

class ImageStackState extends State<ImageStack> {
  double _x = 15;
  double _y = 185;
  double _a = 10;
  double _b = 365;
  final double _textScale = 1.0;
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _quoteController1 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color primaryColour = Theme.of(context).colorScheme.primary;

    return ValueListenableBuilder<String?>(
      valueListenable: widget.selectedImageUrlNotifier,
      builder: (context, selectedImageUrl, _) {
        return RepaintBoundary(
          key: _globalKey,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColour.withOpacity(0.2),
                ),
                child: isGalleryImage
                    ? Image.file(
                        widget.pickedImageFile!,
                        fit: BoxFit.cover,
                      )
                    : selectedImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: selectedImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(), // You can customize the placeholder
                            errorWidget: (context, url, error) => const Icon(Icons
                                .error), // You can customize the error widget
                          )
                        : const SizedBox(),
              ),
              Positioned(
                left: _x,
                top: _y,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _x += details.delta.dx / _textScale;
                      _y += details.delta.dy / _textScale;
                    });
                  },
                  child: Transform.scale(
                    scale: _textScale,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _quoteController,
                            style: GoogleFonts.getFont(
                              selectedFontFamily ?? 'Roboto',
                              textStyle: TextStyle(
                                fontSize: 24,
                                color: selectedColor,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Write your own quote",
                              hintStyle: TextStyle(color: primaryColour),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            cursorWidth: 2,
                            cursorColor: primaryColour,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _a,
                top: _b,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _a += details.delta.dx / _textScale;
                      _b += details.delta.dy / _textScale;
                    });
                  },
                  child: Transform.scale(
                    scale: _textScale,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _quoteController1,
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              color: selectedWriterColor,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "Writer",
                              hintStyle: TextStyle(color: primaryColour),
                              border: InputBorder.none,
                            ),
                            maxLines: 1,
                            cursorWidth: 2,
                            cursorColor: primaryColour,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
