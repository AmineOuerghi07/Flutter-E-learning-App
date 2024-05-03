import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Import Firestore

class SignUpPr extends StatelessWidget {
  const SignUpPr({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Firestore instance
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Text editing controllers to get user input
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController adressController = TextEditingController();

    void _signUp() async {
      // Get user input
      String fullName = fullNameController.text;
      String email = emailController.text;
      String mdp = passwordController.text;
      String confirmmdp = confirmPasswordController.text;
      String adress = adressController.text;
      //String code = codeController.text;
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        print("Email is already used");
      } else {
        // Perform validation if needed before proceeding with signup
        if (mdp == confirmmdp) {
          // Create a new document in the "users" collection with the user data
          _firestore.collection('Users').add({
            'fullName': fullName,
            'email': email,
            'mdp': mdp,
            'adress': adress,
            'animateur': true,
            // You might add more user details as needed
          }).then((value) {
            // Successfully added user data to Firestore
            print('User data added: $value');

            // Now, you can navigate to the home screen or do other actions
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }).catchError((error) {
            // Handle errors if any occurred during document addition
            print('Error adding user data: $error');
            // You can show an error message to the user if required
          });
        } else {
          print("Password is not the same check it !!!");
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: adressController,
              decoration: InputDecoration(
                labelText: 'Adresse',
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: ElevatedButton.icon(
                  onPressed:
                      _signUp, // Call the _signUp function on button press
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    minimumSize: const Size(350, 50),
                  ),
                  icon: Icon(Icons.person_add), // Registration Icon
                  label: const Text('Sign Up'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
