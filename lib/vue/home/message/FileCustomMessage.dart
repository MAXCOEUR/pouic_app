import 'package:cached_network_image/cached_network_image.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LaunchFile.dart';
import 'package:discution_app/vue/home/message/AudioPlayerWidget.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FileCustomMessage extends StatefulWidget {
  final FileModel file;

  const FileCustomMessage(this.file);

  @override
  _FileCustomMessageState createState() => _FileCustomMessageState();
}

class _FileCustomMessageState extends State<FileCustomMessage> {
  late bool _isImage;
  late bool _isVideo;
  late bool _isaudio;
  late VideoPlayerController _controller;
  bool isMute=true;

  @override
  void initState() {
    super.initState();
    _isImage = widget.file.name.toLowerCase().endsWith('.png') ||
        widget.file.name.toLowerCase().endsWith('.jpg') ||
        widget.file.name.toLowerCase().endsWith('.jpeg') ||
        widget.file.name.toLowerCase().endsWith('.gif');
    _isVideo = widget.file.name.toLowerCase().endsWith('.mp4') ||
        widget.file.name.toLowerCase().endsWith('.avi');
    _isaudio = widget.file.name.toLowerCase().endsWith('.mp3') ||
        widget.file.name.toLowerCase().endsWith('.aac');
    if (_isVideo) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    _controller =
    VideoPlayerController.network(Constant.baseUrlFilesMessages + "/" + widget.file.linkFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
        _controller.play();
        _controller.setVolume(0);
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            // Rejouer la vidéo depuis le début à la fin
            _controller.seekTo(Duration(seconds: 0));
            _controller.play();
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onLongPress: () {
          FileGestion.downloadFile(
              Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
              widget.file.name,
              context);
        },
        onTap: () {
          if (_isImage) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PhotoViewCustom(
                      Constant.baseUrlFilesMessages + "/" + widget.file.linkFile)),
            );
          } else {
            FileGestion.Open(
                Constant.baseUrlFilesMessages + "/" + widget.file.linkFile, widget.file.name);
          }
        },
        child: viewFile(widget.file, _isImage, _isVideo, _isaudio),
      ),
    );
  }

  Widget viewFile(FileModel file, bool isImage, bool isVideo, bool isAudio) {
    if (isImage) {
      return imageFileWidget(
          Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isVideo) {
      return buildVideoPlayer(Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isAudio) {
      return audioFileWidget(file);
    } else {
      return genericFileWidget(file);
    }
  }
  Widget imageFileWidget(String url) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500,
      ),
      child: FractionallySizedBox(
        widthFactor: 0.4, // Pour que l'image occupe la moitié de la largeur disponible
        child: CachedNetworkImage(
          imageUrl: url,
          key: Key(url),
          fit: BoxFit.contain,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
  Widget audioFileWidget(FileModel file) {
    return AudioPlayerWidget(
      file: file,
    );
  }

  Widget genericFileWidget(FileModel file) {
    return Column(
      children: [
        Icon(
          Icons.insert_drive_file,
          size: 50,
        ),
        SizedBox(width: SizeMarginPading.h3),
        Container(
          child: Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  Widget buildVideoPlayer(String videoUrl) {
    double videoAspectRatio = _controller.value.aspectRatio;

    return GestureDetector(
      onTap: () {
        if (!_controller.value.isPlaying) {
          _controller.play();
          _controller.setVolume(100);
          isMute = false;
        }
        else if (isMute) {
          _controller.setVolume(100);
          isMute = false;
        } else {
          _controller.setVolume(0);
          isMute = true;
        }

      },
      onLongPress: (){
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
          maxWidth: 500 * videoAspectRatio,
        ),
        child: AspectRatio(
          aspectRatio: videoAspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }
}
