import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:inspirio/themes/theme.dart';
import 'package:inspirio/util/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userName;
  String? userEmail;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userName = user.displayName;
        userEmail = user.email;
        userPhotoUrl = user.photoURL;
      });
    }
  }

  final Uri urlPlayStore = Uri.parse(
      'https://play.google.com/store/apps/dev?id=4846033393809014453');

  Future<void> launchUrlPlayStore() async {
    if (!await launchUrl(urlPlayStore)) {
      throw Exception('Could not launch $urlPlayStore');
    }
  }

  final Uri urlInstagram = Uri.parse('https://www.instagram.com/btr.xd/');

  Future<void> launchUrlInstagram() async {
    if (!await launchUrl(urlInstagram)) {
      throw Exception('Could not launch $urlInstagram');
    }
  }

  final Uri urlTwitter =
      Uri.parse('https://twitter.com/btr__xd?t=idNA9giauYavchbF0ET5YA&s=08');

  Future<void> launchUrlTwitter() async {
    if (!await launchUrl(urlTwitter)) {
      throw Exception('Could not launch $urlTwitter');
    }
  }

  final Uri urlGithub = Uri.parse('https://github.com/BatesharXgit');

  Future<void> launchUrlGithub() async {
    if (!await launchUrl(urlGithub)) {
      throw Exception('Could not launch $urlGithub');
    }
  }

  final Uri urlYoutube = Uri.parse('https://www.youtube.com/@XD.Official');

  Future<void> launchUrlYoutube() async {
    if (!await launchUrl(urlYoutube)) {
      throw Exception('Could not launch $urlYoutube');
    }
  }

// ignore: non_constant_identifier_names
  final Uri _url_report = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.application.inspirio');
// ignore: non_constant_identifier_names
  Future<void> _launchUrl_report() async {
    if (!await launchUrl(_url_report)) {
      throw Exception('Could not launch $_url_report');
    }
  }

  bool showThemeOptions = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColour = Theme.of(context).colorScheme.background;
    Color primaryColour = Theme.of(context).colorScheme.primary;
    Color secondaryColour = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.background,
      //   elevation: 0,
      //   title: Text('Settings'),
      // ),
      backgroundColor: backgroundColour,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                if (userName != null && userEmail != null)
                  Column(
                    children: [
                      if (userPhotoUrl != null)
                        CircleAvatar(
                          radius: 64,
                          backgroundImage:
                              CachedNetworkImageProvider(userPhotoUrl!),
                        ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '$userName',
                        style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: secondaryColour),
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        '$userEmail',
                        style: TextStyle(fontSize: 16, color: primaryColour),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  decoration: BoxDecoration(
                    color: primaryColour.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Iconsax.paintbucket),
                        title: const Text('Change Theme'),
                        iconColor: secondaryColour,
                        textColor: secondaryColour,
                        trailing: Icon(
                          showThemeOptions
                              ? Iconsax.arrow_down
                              : Iconsax.arrow_right,
                        ),
                        onTap: () {
                          setState(() {
                            showThemeOptions = !showThemeOptions;
                          });
                        },
                      ),
                      Visibility(
                        visible: showThemeOptions,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Iconsax.paintbucket),
                              title: const Text('Amoled Theme'),
                              iconColor: secondaryColour,
                              textColor: secondaryColour,
                              trailing: const Icon(Iconsax.arrow_right),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Iconsax.paintbucket),
                              title: const Text('Light Theme'),
                              iconColor: secondaryColour,
                              textColor: secondaryColour,
                              trailing: const Icon(Iconsax.arrow_right),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Iconsax.paintbucket),
                              title: const Text('Coloured Theme'),
                              iconColor: secondaryColour,
                              textColor: secondaryColour,
                              trailing: const Icon(Iconsax.arrow_right),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  decoration: BoxDecoration(
                    color: primaryColour.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('Report a Bug'),
                    iconColor: secondaryColour,
                    textColor: secondaryColour,
                    trailing: const Icon(Iconsax.arrow_right),
                    onTap: () {
                      _launchUrl_report();
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  decoration: BoxDecoration(
                    color: primaryColour.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Iconsax.logout),
                    title: const Text('Log Out'),
                    iconColor: secondaryColour,
                    textColor: secondaryColour,
                    trailing: const Icon(Iconsax.arrow_right),
                    onTap: () => FirebaseAuth.instance.signOut(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  decoration: BoxDecoration(
                    color: primaryColour.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Iconsax.back_square),
                    title: const Text('Exit'),
                    iconColor: secondaryColour,
                    textColor: secondaryColour,
                    trailing: const Icon(Iconsax.arrow_right),
                    onTap: () {
                      SystemNavigator.pop();
                    },
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Contact Us On:',
                  style: TextStyle(
                    color: primaryColour,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: launchUrlPlayStore,
                        child: Icon(
                          BootstrapIcons.google_play,
                          color: secondaryColour,
                          size: 32,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: launchUrlInstagram,
                        child: Icon(
                          BootstrapIcons.instagram,
                          color: secondaryColour,
                          size: 32,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: launchUrlTwitter,
                        child: Icon(
                          BootstrapIcons.twitter,
                          color: secondaryColour,
                          size: 32,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: launchUrlGithub,
                        child: Icon(
                          BootstrapIcons.github,
                          color: secondaryColour,
                          size: 32,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: launchUrlYoutube,
                        child: Icon(
                          BootstrapIcons.youtube,
                          color: secondaryColour,
                          size: 32,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Inspirio v 1.1.0',
                    style:
                        GoogleFonts.kanit(color: primaryColour, fontSize: 10),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Made in India.',
                    style:
                        GoogleFonts.kanit(color: primaryColour, fontSize: 10),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
