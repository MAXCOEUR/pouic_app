import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:pouic/outil/LaunchFile.dart';
import 'package:pouic/vue/home/message/AudioPlayerWidget.dart';
import 'package:pouic/vue/widget/PhotoView.dart';
import 'package:pouic/vue/widget/VideoView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FileCustomMessage extends StatefulWidget {
  final FileModel file;

  const FileCustomMessage(this.file);

  @override
  _FileCustomMessageState createState() => _FileCustomMessageState();

  static Widget generateFileCustomMessages(List<FileModel> files,BuildContext context) {
    if (files.length == 1) {
      // Cas où il y a un seul élément
      return ClipRRect(
        borderRadius: BorderRadius.circular(SizeBorder.radius), // Définissez le rayon de bordure souhaité
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 700,
            maxHeight: 500,
          ),
          child: FileCustomMessage(files[0]),
        ),
      );
    } else {

      return Container(
        padding: EdgeInsets.all(SizeMarginPading.h3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeBorder.radius),
          color: Theme.of(context).colorScheme.surface,
        ),
        constraints: BoxConstraints(
          maxWidth: 700,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final containerWidth = constraints.maxWidth;
            final itemWidth = containerWidth / 2-10; // Moitié de la largeur du conteneur

            return Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: List.generate(files.length, (index) {
                return Container(
                  width: itemWidth,
                  constraints: BoxConstraints(
                    maxWidth: 300,
                    maxHeight: 300,
                  ),
                  margin: EdgeInsets.all(SizeMarginPading.p1),
                  child: FileCustomMessage(files[index]),
                );

              }),
            );
          },
        ),
      );

    }
  }
}

class _FileCustomMessageState extends State<FileCustomMessage> {
  late bool _isImage;
  late bool _isVideo;
  late bool _isaudio;
  late VideoPlayerController _controller;
  bool isMute = true;

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
    _controller = VideoPlayerController.network(
        Constant.baseUrlFilesMessages + "/" + widget.file.linkFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
        _controller.setVolume(0);
        _controller.play();
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
      child: viewFile(widget.file, _isImage, _isVideo, _isaudio),
    );
  }

  Widget viewFile(FileModel file, bool isImage, bool isVideo, bool isAudio) {
    if (isImage) {
      return imageFileWidget(
          Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isVideo) {
      return buildVideoPlayer(
          Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isAudio) {
      return audioFileWidget(file);
    } else {
      return genericFileWidget(file);
    }
  }

  Widget imageFileWidget(String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PhotoViewCustom(
                  Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
                ),
          ),
        );
      },
      child: CachedNetworkImage(
        imageUrl: url,
        key: Key(url),
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),

    );
  }

  Widget audioFileWidget(FileModel file) {
    return GestureDetector(
      onLongPress: () {
        FileGestion.Open(
            Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
            widget.file.name);
      },
      child: AudioPlayerWidget(
        file: file,
      ),
    );
  }

  Widget genericFileWidget(FileModel file) {
    return GestureDetector(
      onTap: () {
        FileGestion.Open(
            Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
            widget.file.name);
      },
      child: Container(
        height: 75,
        child: Column(
          children: [
            Icon(
              Icons.file_open,
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
        ),
      ),);
  }

  Widget buildVideoPlayer(String videoUrl) {
    double videoAspectRatio = _controller.value.aspectRatio;
    Icon mute = Icon(Icons.volume_off);
    Icon unMute = Icon(Icons.volume_up);
    if (!kIsWeb && Platform.isWindows) {
      return GestureDetector(
        onTapDown: (value) {
          FileGestion.Open(
            Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
            widget.file.name,
          );
        },
        onLongPress: () {
          FileGestion.Open(
            Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
            widget.file.name,
          );
        },
        child:genericFileWidget(widget.file));
    } else {
      return GestureDetector(
        onTapDown: (value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VideoViewCustom(
                      Constant.baseUrlFilesMessages + "/" +
                          widget.file.linkFile,
                    ),
              ),
            );

        },
        onLongPress: () {
          FileGestion.Open(
            Constant.baseUrlFilesMessages + "/" + widget.file.linkFile,
            widget.file.name,
          );
        },
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: videoAspectRatio,
              child: VideoPlayer(_controller),
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.all(SizeMarginPading.h3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .background
                      .withOpacity(0.5), // Couleur noire avec opacité de 50%
                ),
                child: IconButton(
                  onPressed: () {
                    if (isMute) {
                      _controller.setVolume(100);
                    } else {
                      _controller.setVolume(0);
                    }
                    setState(() {
                      isMute = !isMute;
                    });
                  },
                  icon: (isMute) ? mute : unMute,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_isVideo) {
      _controller.dispose();
    }
    super.dispose();
  }

}
