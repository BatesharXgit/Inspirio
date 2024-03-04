import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inspirio/authentication/auth%20pages/login_page.dart';
import 'package:inspirio/pages/inspirioPages/homepage.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const InspirioHome();
            } else {
              return const LoginPage();
              // return const InspirioHome();
            }
          }),
    );
  }
}