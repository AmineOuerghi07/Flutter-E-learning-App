import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modernlogintute/pages/course.dart';
import 'profile.dart'; // Import the ProfileScreen class
import 'package:modernlogintute/user_model.dart';
import 'package:provider/provider.dart';
import 'package:modernlogintute/changeNotif.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text editing controllers to get user input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() async {
    try {
      // Get user input
      String email = emailController.text;
      String password = passwordController.text;

      // Query Firestore to find the user with the provided email
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Check if the user exists and the password matches
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        String storedPassword = userSnapshot.get('mdp');

        if (password == storedPassword) {
          // Passwords match, login is successful
          // ignore: use_build_context_synchronously
          User userData = User(
            fullName: userSnapshot.get('fullName'), // Replace with the user's name fetched from Firestore
            email: email, // Replace with the user's email fetched from Firestore
            adress: userSnapshot.get('adress'),
            mdp: storedPassword,
            animateur: userSnapshot.get('animateur'),
            docID: userSnapshot.id
             // Replace with the user's age fetched from Firestore
          );
          UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.updateUserData(userData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CoursePage()),
          );
        } else {
          // Password doesn't match, show an error message
          print('Incorrect password.');
          // You can show an error message to the user if required
        }
      } else {
        // User not found, show an error message
        print('User not found.');
        // You can show an error message to the user if required
      }
    } catch (e) {
      // Handle any errors that occurred during the login process
      print('Error during login: $e');
      // You can show an error message to the user if required
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}