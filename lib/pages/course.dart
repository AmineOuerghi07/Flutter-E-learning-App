import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'home.dart';
import 'profile.dart';
import 'upload.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:modernlogintute/user_model.dart';
import 'package:modernlogintute/changeNotif.dart';
import 'package:provider/provider.dart';

class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
   
  int _currentIndex = 0;
  final parentFolder = 'videos'; // Path to the parent folder
  List<Reference>? folderList; // List to store folder references

  @override
  void initState() {
    super.initState();
    _fetchFolders(); // Fetch the list of folders
  }

  Future<void> _fetchFolders() async {
    try {
      // Get the list of items (files and folders) in the parent folder
      final ListResult result =
          await FirebaseStorage.instance.ref(parentFolder).listAll();

      // Convert items to references
      folderList = result.prefixes;

      setState(() {}); // Update the UI to display the folders
    } catch (e) {
      print('Error fetching folders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    User user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.fullName),
              accountEmail: Text(user.email),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/profile_picture.png'),
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
            if(user.animateur == true)
            ListTile(
              title: const Text('Uploads'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // Add more ListTiles for additional options as needed
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the list of folders
            if (folderList != null)
              Expanded(
                child: ListView.builder(
                  itemCount: folderList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final folder = folderList![index];
                    return FolderItem(
                      folder: folder,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            // Navigate to FavoritesScreen
            // Add the navigation logic here
          } else if (index == 1) {
            // Navigate to SearchScreen
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ),
            );*/
          } else if (index == 2) {
            // Navigate to ContactUsScreen
            // Add the navigation logic here
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'My Fav',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Contact Us',
          ),
        ],
      ),
    );
  }
}

// Recursive widget to display folders


class FolderContentPage extends StatelessWidget {
  final String folderPath;
  bool isFolder = false;


  FolderContentPage({required this.folderPath});

  Future<List<Reference>> _fetchFolderContents() async {
    try {
      final ListResult result =
          await FirebaseStorage.instance.ref(folderPath).listAll();
      if(result.prefixes.isEmpty)
      {
        isFolder = false;
        return result.items;
      }
      else
      {
        isFolder = true;
        return result.prefixes;
      }
    } catch (e) {
      print("Error fetching folder contents: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folder Contents'),
      ),
      body: FutureBuilder<List<Reference>>(
        future: _fetchFolderContents(),
        builder: (context, result) {
          if (result.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (result.hasError) {
            return Center(child: Text('Error fetching folder contents'));
          } else if (!result.hasData || result.data!.isEmpty) {
            return Center(child: Text('Folder is empty $folderPath'));
          } else {
            final List<Reference> contents = result.data!;
            return ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final item = contents[index];
                if(isFolder)
                {
                  return FolderItem(folder: item);
                }
                else
                {
                  return FileItem(file: item);
                }
              },
            );
          }
        },
      ),
    );
  }
}

// Recursive widget to display folders, videos, and other files
class FolderItem extends StatelessWidget {
  final Reference folder;

  FolderItem({required this.folder});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to the contents of the selected folder
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderContentPage(
              folderPath: folder.fullPath,
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 16.0 + 16.0 * folder.fullPath.split('/').length),
        child: Row(
          children: [
            Icon(Icons.folder),
            SizedBox(width: 10),
            Text(
              folder.name,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder widget for video items (customize as needed)
class VideoItem extends StatelessWidget {
  final Reference video;

  VideoItem({required this.video});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.video_library),
      title: Text(video.name),
      onTap: () {
        // Handle tapping on a video item here
        // You can navigate to video player or take any action as needed
      },
    );
  }
}

// Placeholder widget for other file items (customize as needed)


class FileItem extends StatelessWidget {
  final Reference file;

  FileItem({required this.file});

  Future<void> _downloadAndOpenFile(BuildContext context) async {
    try {
      final String downloadUrl = await file.getDownloadURL();
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/${file.name}';
      final File localFile = File(filePath);

      final task = FirebaseStorage.instance.ref(file.fullPath).writeToFile(localFile);
      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes);
        print('Download progress: $progress');
        // You can update the progress indicator here
      });

      await task;
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print('Error opening file: ${result.message}');
      }
    } catch (e) {
      print('Error downloading or opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.insert_drive_file),
      title: Text(file.name),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Downloading'),
              content: LinearProgressIndicator(),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        _downloadAndOpenFile(context);
      },
    );
  }
}