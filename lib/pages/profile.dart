import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modernlogintute/changeNotif.dart';
import 'package:modernlogintute/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  QuerySnapshot? querySnapshot;
  String name = '5edmet amine';
  String phone = '1234567890';
  String address = '123 Street, City';
  String email = '';
  List<String> courseHistory = ['Course A', 'Course B', 'Course C'];
  bool changed = false;

  void editProfile() async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    User user = userProvider.user;
    final editedProfile = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? editedName;
        String? editedPhone;
        String? editedAddress;
        String? editedEmail;

        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    editedName = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  onChanged: (value) {
                    editedPhone = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Address'),
                  onChanged: (value) {
                    editedAddress = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    editedEmail = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': editedName,
                  'phone': editedPhone,
                  'address': editedAddress,
                  'email': editedEmail,
                });
                email = editedEmail.toString();
                getEmail();
                if(querySnapshot!.docs.isEmpty)
                {
                  usersCollection.doc(user.docID).update({
                  'fullName': editedName,
                  'email': editedEmail,
                  'adress': editedAddress,
                }).then((_) {
                  print('Document updated successfully.');
                  user.fullName = editedName.toString();
                  user.email = editedEmail.toString();
                  user.adress = editedAddress.toString();
                  changed = true;
                }).catchError((error) {
                  print('Error updating document: $error');
                  changed = false;
                });
                }
                else
                {
                  print("Email is already used");
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (changed) {
      setState(() {
        user.fullName = editedProfile['name'] ?? user.fullName;
        user.mdp = editedProfile['phone'] ?? user.mdp;
        user.adress = editedProfile['address'] ?? user.adress;
        user.email = editedProfile['email'] ?? user.email;
      });
    }
  }
  void getEmail() async
  {
    querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();
  }
  void viewCourseHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Course History'),
          content: Column(
            children: [
              for (String course in courseHistory)
                ListTile(
                  title: Text(course),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    User user = userProvider.user;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 70,
              //backgroundImage: AssetImage('assets/images/user.JPG'),
            ),
            const SizedBox(height: 20),
            itemProfile('Name', user.fullName, Icons.person),
            const SizedBox(height: 10),
            itemProfile('Phone', user.mdp, Icons.phone),
            const SizedBox(height: 10),
            itemProfile('Address', user.adress, Icons.location_on),
            const SizedBox(height: 10),
            itemProfile('Email', user.email, Icons.email),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: editProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  primary: Colors.grey,
                  onPrimary: Colors.black,
                ),
                child: const Text('Edit Profile'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: viewCourseHistory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  primary: Colors.grey,
                  onPrimary: Colors.black,
                ),
                child: const Text('View Course History'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 5),
            color: Colors.black12,
            spreadRadius: 2,
            blurRadius: 10,
          )
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        leading: Icon(
          iconData,
          color: Colors.black,
        ),
        trailing: const Icon(
          Icons.arrow_forward,
          color: Colors.grey,
        ),
        tileColor: Colors.white,
      ),
    );
  }
}
