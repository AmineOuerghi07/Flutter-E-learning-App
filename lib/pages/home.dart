import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'lib/images/mylogo.png', // Replace with your logo file name and path
                  width: 400, // Adjust the width as needed
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /*Image.asset(
                    'lib/images/bg.png',
                    scale: 2,
                  ),*/
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to SignUpScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        onPrimary: Colors.white,
                        minimumSize: const Size(150, 50),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('se connecter'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Perform Google login
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 0, 0, 0),
                          onPrimary: Color.fromARGB(255, 255, 255, 255),
                          minimumSize: const Size(150, 50),
                        ),
                        icon: const Icon(Icons.g_translate),
                        label: const Text('Google Login'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Perform Facebook login
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 0, 0, 0),
                          onPrimary: Color.fromARGB(255, 255, 255, 255),
                          minimumSize: const Size(150, 50),
                        ),
                        icon: const Icon(Icons.facebook),
                        label: const Text('Facebook Login'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Navigate to CreateAccountScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
