import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inspirio/pages/category.dart';
import 'package:inspirio/services/admob_services.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final Reference foryouRef = FirebaseStorage.instance.ref().child('categoryimg');

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  State<Category> createState() => CategoryState();
}

class CategoryState extends State<Category> {
  final List<String> _imageReferences1 = [
    'categoryimg/morning.jpg',
    'categoryimg/birthday.jpg',
    'categoryimg/religious.jpg',
    'categoryimg/avengers.jpg',
    'categoryimg/movies.jpg',
    'categoryimg/best wishes.jpg',
    'categoryimg/success.jpg',
    'categoryimg/fitness.jpg',
    'categoryimg/courage.jpg',
    'categoryimg/power.jpg'
  ];
  final List<String> _imageReferences2 = [
    'categoryimg/night.jpg',
    'categoryimg/inspirational.jpg',
    'categoryimg/leadership.jpg',
    'categoryimg/happiness.jpg',
    'categoryimg/hindi.jpg',
    'categoryimg/friendship.jpg',
    'categoryimg/motivational.jpg',
    'categoryimg/nature.jpg',
    'categoryimg/business.jpg',
    'categoryimg/wisdom.jpg'
  ];
  final List<String> categories = [
    'Morning', //done
    'Night',
    'Birthday',
    'Inspirational',
    'Religious',
    'Leadership',
    'Avengers', //done
    'Happiness',
    'Movies',
    'Hindi',
    'Best Wishes',
    'Friendship',
    'Success',
    'Motivational',
    'Fitness',
    'Nature',
    'Courage',
    'Business',
    'Power',
    'Wisdom',
  ];

  final List<String> filteredCategories = [];

  final TextEditingController searchController = TextEditingController();

  // bool showSearchBox = true;
  // bool categoryFound = true;

  @override
  void initState() {
    filteredCategories.addAll(categories);
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
  }

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

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        backgroundColor: backgroundColour,
        iconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        title: Text(
          "Browse Categories",
          style: GoogleFonts.kanit(
            fontSize: 22,
            color: secondaryColour,
          ),
        ),
      ),
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.012,
            ),
            // buildSearchBox(),

            Expanded(
              child: ListView.builder(
                itemCount: (filteredCategories.length / 2).ceil(),
                itemBuilder: (BuildContext context, int index) {
                  final rowIndex = index * 2;
                  final category1 = filteredCategories[rowIndex];
                  final category2 = (rowIndex + 1 < filteredCategories.length)
                      ? filteredCategories[rowIndex + 1]
                      : null;
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    decoration: BoxDecoration(
                                      color: primaryColour.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColour.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(1, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            category1,
                                            style: GoogleFonts.kanit(
                                              color: secondaryColour,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildCachedImage(
                                              _imageReferences1[index]),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    _showInterstitialAd();
                                    _navigateToCategoryPage(category1, context);
                                  },
                                  // onTap: () => _navigateToCategoryPage(category1),
                                ),
                              ),
                              if (category2 != null) const SizedBox(width: 10),
                              if (category2 != null)
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.12,
                                      decoration: BoxDecoration(
                                        color: primaryColour.withOpacity(0.6),
                                        border: Border.all(
                                            width: 0.2,
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                primaryColour.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(1, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              category2,
                                              style: GoogleFonts.kanit(
                                                color: secondaryColour,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildCachedImage(
                                                _imageReferences2[index]),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      _navigateToCategoryPage(
                                          category2, context);
                                    },
                                    // onTap: () => _navigateToCategoryPage(category2),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: _banner == null
          ? null
          : SizedBox(
              height: 52,
              child: AdWidget(ad: _banner!),
            ),
    );
  }

  Widget _buildCachedImage(String imageReference) {
    final ref = storage.ref().child(imageReference);
    return FutureBuilder<String>(
      future: ref.getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final imageUrl = snapshot.data!;
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.height * 0.1,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // Widget buildSearchBox() {
  //   Color primaryColour = Theme.of(context).colorScheme.primary;
  //   Color secondaryColour = Theme.of(context).colorScheme.secondary;
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
  //     child: Container(
  //       width: MediaQuery.of(context).size.width * 0.88,
  //       height: MediaQuery.of(context).size.height * 0.056,
  //       decoration: BoxDecoration(
  //         color: primaryColour.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.5),
  //             spreadRadius: 2,
  //             blurRadius: 5,
  //             offset: const Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: TextField(
  //                 controller: searchController,
  //                 style: GoogleFonts.kanit(
  //                   fontSize: 18,
  //                   color: secondaryColour,
  //                 ),
  //                 decoration: InputDecoration(
  //                   hintText: 'Which Category you are lookin for...',
  //                   hintStyle: GoogleFonts.kanit(
  //                     color: secondaryColour.withOpacity(0.8),
  //                     fontSize: 16,
  //                   ),
  //                   border: InputBorder.none,
  //                   suffixIcon: IconButton(
  //                     icon: const Icon(
  //                       Icons.clear,
  //                       color: Colors.grey,
  //                     ),
  //                     onPressed: () {
  //                       searchController.clear();
  //                       filterCategories('');
  //                       setState(() {
  //                         showSearchBox = false;
  //                       });
  //                     },
  //                   ),
  //                 ),
  //                 onChanged: (value) {
  //                   filterCategories(value);
  //                 },
  //                 onSubmitted: (value) {
  //                   filterCategories(value);
  //                 },
  //                 cursorColor: const Color(0xFF831A2B),
  //                 cursorRadius: const Radius.circular(20),
  //                 cursorWidth: 3,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void filterCategories(String query) {
  //   setState(() {
  //     if (query.isEmpty) {
  //       filteredCategories.clear();
  //       filteredCategories.addAll(categories);
  //     } else {
  //       filteredCategories.clear();
  //       filteredCategories.addAll(categories.where((category) =>
  //           category.toLowerCase().contains(query.toLowerCase())));
  //     }

  //     categoryFound = filteredCategories.isNotEmpty;
  //   });
  // }
}

void _navigateToCategoryPage(String category, context) {
  switch (category) {
    case 'Morning':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'home/morning',
          ),
        ),
      );

      break;
    case 'Night':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/night',
          ),
        ),
      );
      break;
    case 'Birthday':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/birthday',
          ),
        ),
      );
      break;
    case 'Inspirational':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/inspirational',
          ),
        ),
      );
      break;
    case 'Religious':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/religious',
          ),
        ),
      );
      break;
    case 'Leadership':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/leadership',
          ),
        ),
      );
      break;
    case 'Avengers':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/avengers',
          ),
        ),
      );
      break;
    case 'Happiness':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/happiness',
          ),
        ),
      );
      break;
    case 'Movies':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/movies',
          ),
        ),
      );
      break;
    case 'Hindi':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'home/hindi',
          ),
        ),
      );
      break;
    case 'Best Wishes':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/bestwishes',
          ),
        ),
      );
      break;
    case 'Friendship':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/friendship',
          ),
        ),
      );
      break;

    case 'Success':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/success',
          ),
        ),
      );
      break;
    case 'Motivational':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'home/motivational',
          ),
        ),
      );
      break;

    case 'Fitness':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/fitness',
          ),
        ),
      );
      break;
    case 'Nature':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/nature',
          ),
        ),
      );
      break;
    case 'Courage':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/courage',
          ),
        ),
      );
      break;
    case 'Business':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/business',
          ),
        ),
      );
      break;
    case 'Power':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/power',
          ),
        ),
      );
      break;
    case 'Wisdom':
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CategoryPage(
            reference: 'category/wisdom',
          ),
        ),
      );
      break;
    default:
      break;
  }
}
