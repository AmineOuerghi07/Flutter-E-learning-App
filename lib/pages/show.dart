import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class VideoListPage extends StatefulWidget {
  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<String> videoUrls = [];

  Future<void> _fetchVideoUrls() async {
    try {
      // Reference to the Firebase Storage bucket and folder
      Reference storageRef = FirebaseStorage.instance.ref().child('files');

      // List all items (videos) in the folder
      ListResult listResult = await storageRef.listAll();

      // Loop through each item and fetch the download URL
      for (var item in listResult.items) {
        String videoUrl = await item.getDownloadURL();
        videoUrls.add(videoUrl);
      }

      setState(() {
        // Trigger a rebuild to show the fetched videos in the UI
      });
    } catch (e) {
      print('Error fetching video URLs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVideoUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video List')),
      body: ListView.builder(
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return VideoPlayerWidget(videoUrl: videoUrls[index]);
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
