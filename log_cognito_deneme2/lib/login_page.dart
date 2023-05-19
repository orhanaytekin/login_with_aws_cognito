import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:log_cognito/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int _countTapped = 0;

  // Create an instance of the Cognito UserPool
  final userPool = CognitoUserPool(
    'us-east-1_y7v1WiRDC',
    '4qlgsbk6dg3bbugf48ea6mdlq9',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onLongPress: () => _admin(3),
                  onDoubleTap: () => _admin(2),
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.2,
                    backgroundImage: const AssetImage('assets/open.jpg'),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot Your Password?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onLongPress: () => {_countTapped = 0},
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () =>
                          {Navigator.pushNamed(context, '/signup')},
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // For admin access without the password
  void _admin(int count) {
    _countTapped += count;
    print(_countTapped);
    if (_countTapped == 11) {
      _countTapped = 0;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MainPage(isFromAdminConsole: true)));
    }
  }

  // change the user's current password if it is forgotten and verification completes
  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final emailController = TextEditingController();

        return AlertDialog(
          title: const Text('Forgot Password'),
          content: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your email to reset the password:'),
                TextField(
                  controller: emailController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                emailController.text.isEmpty
                    ? showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                const Color.fromARGB(255, 13, 232, 228),
                            title: const Text('Forgot Password Failed'),
                            content: const Text('Email can\'t be empty'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      )
                    : Navigator.pop(context, emailController.text);
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );

    if (email != null && email.isNotEmpty) {
      final cognitoUser = CognitoUser(
        email,
        userPool,
      );

      try {
        await cognitoUser.forgotPassword();

        final verificationCodeController = TextEditingController();
        final newPasswordController = TextEditingController();

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('An email has been sent to reset your password.'),
                  TextField(
                    controller: verificationCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                    ),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final verificationCode =
                        verificationCodeController.text.trim();
                    final newPassword = newPasswordController.text.trim();

                    if (verificationCode.isNotEmpty && newPassword.isNotEmpty) {
                      try {
                        await cognitoUser.confirmPassword(
                            verificationCode, newPassword);

                        Navigator.pop(context); // Close the dialog

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Password Reset Successful'),
                              content:
                                  const Text('Your password has been reset.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } catch (e) {
                        String errorMessage = e.toString();
                        errorMessage = errorMessage
                            .split("message: ")[1]
                            .replaceFirst(RegExp(r'}'), '');

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Password Reset Failed'),
                              content: Text(errorMessage),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Text('Confirm Password'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        String errorMessage = e.toString();
        errorMessage =
            errorMessage.split("message: ")[1].replaceFirst(RegExp(r'}'), '');

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Forgot Password Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Login function
  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final cognitoUser = CognitoUser(
      email,
      userPool,
    );

    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    try {
      final authResult = await cognitoUser.authenticateUser(authDetails);

      // User is logged in successfully, navigate to the main page
      Navigator.pushNamed(context, '/main');
    } catch (e) {
      String errorMessage = e.toString();
      errorMessage =
          errorMessage.split("message: ")[1].replaceFirst(RegExp(r'}'), '');
      // Handle login error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
