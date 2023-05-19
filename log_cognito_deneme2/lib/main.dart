import 'package:flutter/material.dart';
import 'package:log_cognito/login_page.dart';
import 'package:log_cognito/main_page.dart';
import 'package:log_cognito/signup_page.dart';
import 'package:log_cognito/splash_page.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/main': (context) => const MainPage(
              isFromAdminConsole: false,
            ),
      },
    );
  }
}
