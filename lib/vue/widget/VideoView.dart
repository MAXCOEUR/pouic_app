import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:pouic/vue/widget/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class VideoViewCustom extends StatefulWidget {
  final String url;

  VideoViewCustom(this.url);

  @override
  _VideoViewCustomState createState() => _VideoViewCustomState();
}

class _VideoViewCustomState extends State<VideoViewCustom> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      placeholder:const Center(child: CircularProgressIndicator(),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(arrowReturn: true),
      body: Container(child: Chewie(
        controller: _chewieController,
      ),
    ),);
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }
}
