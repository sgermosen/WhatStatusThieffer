import 'dart:io';

import 'package:flutter/material.dart';
import 'package:status_saver/app/app.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayVideo extends StatefulWidget {
  final String videoSrc;

  PlayVideo({
    required this.videoSrc,
    super.key,
  });

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  // Variables
  final App _app = new App();
  late final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late final Future<void> _future;

  // Initialize video player
  Future<void> _initVideoPlayer() async {
    // print(File(widget.videoSrc));

    _videoPlayerController = VideoPlayerController.file(File(widget.videoSrc));

    // important: initialize _videoPlayerController to get correct video aspect ratio
    await _videoPlayerController.initialize();

    // Get Auto Play Video Prefs
    final bool _autoPlayVideo = await _app.getAutoPlayVideo();

    //  print(_videoPlayerController.value.aspectRatio);

    if (!mounted) return;
    setState(() {
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoInitialize: true,
          allowFullScreen: true,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: _autoPlayVideo,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(errorMessage),
            );
          });
    });
  }

  @override
  void initState() {
    super.initState();
    _future = _initVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          final chewie = _chewieController;
          if (snapshot.connectionState == ConnectionState.done &&
              chewie != null) {
            return Hero(
              tag: widget.videoSrc,
              child: Chewie(
                controller: chewie,
              ),
            );
          } else {
            return AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset("assets/images/video_loader.gif",
                    fit: BoxFit.cover));
          }
        });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}
