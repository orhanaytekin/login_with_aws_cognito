import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _fullNameController;
  // DateTime? _selectedDate;

  String verificationCode = '';

  final userPool = CognitoUserPool(
    'us-east-1_y7v1WiRDC',
    '4qlgsbk6dg3bbugf48ea6mdlq9',
  );

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _fullNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

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
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.2,
                  foregroundImage: const AssetImage('assets/open.jpg'),
                ),
                const SizedBox(height: 16.0),
                const Text(' * is for required fields, others are optional.'),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email*',
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
                    labelText: 'Password*',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password*',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get the birthdate of an user -- (for the future references, decided not to use it)
  // Future<void> _selectDate() async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime.now(),
  //   );
  //   if (pickedDate != null) {
  //     setState(() {
  //       _selectedDate = pickedDate;
  //     });
  //   }
  // }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final fullName = _fullNameController.text.trim();
    // final birthdate = _selectedDate != null ? _selectedDate!.toString() : '';
    const birthdate = '';

    if (password != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Passwords do not match.'),
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
      return;
    }

    final userAttributes = [
      AttributeArg(name: 'email', value: email),
      AttributeArg(name: 'name', value: fullName),
      const AttributeArg(name: 'birthdate', value: birthdate),
    ];

    try {
      final signupData = await userPool.signUp(
        email,
        password,
        userAttributes: userAttributes,
      );

      _showConfirmationDialog(signupData.user);
    } catch (e) {
      String errorMessage = e.toString();
      errorMessage =
          errorMessage.split("message: ")[1].replaceFirst(RegExp(r'}'), '');
      // Check if the error indicates that the user already exists but is not confirmed
      if (errorMessage.toLowerCase().contains('already exists')) {
        final user = CognitoUser(email, userPool);
        final verifyController = TextEditingController();
        String verify = '';

        try {
          await user.resendConfirmationCode();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('User Already Exists'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'An email has been sent to your email address. Please check your inbox and verify your account.',
                    ),
                    TextFormField(
                      onChanged: (value) {
                        verify = value;
                      },
                      controller: verifyController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmation Code',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        await user.confirmRegistration(verify);
                      } catch (e) {
                        rethrow;
                      }
                      Navigator.popAndPushNamed(context, '/main');
                    },
                    child: const Text('Verify'),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          String resendErrorMessage = e.toString();
          resendErrorMessage = resendErrorMessage
              .split("message: ")[1]
              .replaceFirst(RegExp(r'}'), '');

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Resend Confirmation Failed'),
                content: Text(resendErrorMessage),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Signup Failed'),
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

  // Send a mail to the user's email address and confirm it
  void _showConfirmationDialog(CognitoUser user) {
    final confirmationCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Confirmation code sent to your email.'),
              TextFormField(
                onChanged: (value) {
                  verificationCode = value;
                },
                controller: confirmationCodeController,
                decoration: const InputDecoration(
                  labelText: 'Confirmation Code',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                verificationCode = confirmationCodeController.text;

                if (verificationCode.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content:
                            const Text('Please enter the confirmation code.'),
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
                  return;
                }

                try {
                  await user.confirmRegistration(verificationCode);
                  Navigator.pop(context);
                  _signIn();
                } catch (e) {
                  String errorMessage = e.toString();
                  errorMessage = errorMessage
                      .split("message: ")[1]
                      .replaceFirst(RegExp(r'}'), '');

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation Failed'),
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
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  // navigate to the main page after the sign in
  void _signIn() {
    Navigator.pushNamed(context, '/main');
  }
}
