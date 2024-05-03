import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:modernlogintute/user_model.dart';
import 'package:provider/provider.dart';
import 'package:modernlogintute/changeNotif.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  double _uploadProgress = 0.0;

  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  String? thumbnailPath;
  String description = ""; // Added a variable to store the entered description
  String cours = "";

  List<String> schoolSubjects = [
    "Mathématiques",
    "Sciences",
    "Histoire",
    "Géographie",
    "Français",
    "Informatique",
    "Physique"
    // Add more subjects as needed
  ];

  String selectedSubject = "Mathématiques";

  Future _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
      if (_videoController != null) {
        _videoController!.dispose();
      }
      _videoController = VideoPlayerController.file(File(pickedFile!.path!));
      _initializeVideoPlayerFuture = _videoController!.initialize();

      // Generate video thumbnail using video_thumbnail package
      _generateThumbnail(pickedFile!.path!);
    });
  }

  Future _generateThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,
      quality: 25,
    );

    setState(() {
      this.thumbnailPath = thumbnailPath;
    });
  }

  Future _uploadFile() async {
    
    if (pickedFile == null || description == "" || cours == "") return;
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    User user = userProvider.user;
    final videoPath = pickedFile!.path!;
    final videoFile = File(videoPath);
    description = description.toLowerCase();
    String s = pickedFile!.name;
    int index = s.lastIndexOf('.');
    final String fileName = cours + s.substring(index, s.length);
    final path = 'videos/$selectedSubject/Prof ${user.fullName}/$description/$fileName';
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(videoFile);

    uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = snapshot.bytesTransferred.toDouble() /
            snapshot.totalBytes.toDouble();
      });
    });

    await uploadTask!.whenComplete(() {
      print('Video Uploaded');
      setState(() {
        uploadTask = null; // Reset the uploadTask when upload is complete
        _uploadProgress = 0.0; // Reset the progress value
      });
    });
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Upload Page"),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dropdown to select a subject
            DropdownButton<String>(
              value: selectedSubject,
              onChanged: (value) {
                setState(() {
                  selectedSubject = value!;
                });
              },
              items: schoolSubjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Display the selected subject
            Text(
              "Selected Subject: $selectedSubject",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Button to select a video
            ElevatedButton(
              onPressed: _selectFile,
              child: Text("Select Video"),
            ),
            SizedBox(height: 20),

            // Display the video preview or thumbnail
            if (pickedFile != null)
              Column(
                children: [
                  // Video preview or thumbnail
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: _videoController != null
                        ? FutureBuilder(
                            future: _initializeVideoPlayerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return VideoPlayer(_videoController!);
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          )
                        : Image.file(
                            File(thumbnailPath!),
                            height: 100,
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Input field for "Nom Chapitre" (description)
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Nom Chapitre',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input field for "cours"
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        cours = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cours',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Button to upload the video
                  ElevatedButton(
                    onPressed: _uploadFile,
                    child: const Text("Upload Video"),
                  ),

                  // Display the uploaded video thumbnail
                  if (thumbnailPath != null)
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Image.file(
                          File(thumbnailPath!),
                          height: 100,
                        ),
                      ],
                    ),

                  // Display the upload progress
                  if (_videoController != null)
                    Column(
                      children: [
                        SizedBox(height: 20),
                        if (uploadTask != null)
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: _uploadProgress,
                              backgroundColor: Colors.grey,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                      ],
                    ),

                  SizedBox(height: 20),

                  // Display the entered description
                  Text(
                    "Nom de Chapitre: $description",
                    style: TextStyle(fontSize: 16),
                  ),

                  // Display the entered cours
                  Text(
                    "Cours: $cours",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
}