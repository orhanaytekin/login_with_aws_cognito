import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  final bool isFromAdminConsole;

  const MainPage({super.key, required this.isFromAdminConsole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => {
            Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false)
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: isFromAdminConsole
                    ? const AssetImage('assets/admin.jpg')
                    : const AssetImage('assets/open.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
