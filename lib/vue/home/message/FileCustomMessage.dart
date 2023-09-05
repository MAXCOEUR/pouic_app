import 'package:cached_network_image/cached_network_image.dart';
import 'package:discution_app/Model/FileModel.dart';
import 'package:discution_app/outil/Constant.dart';
import 'package:discution_app/outil/LaunchFile.dart';
import 'package:discution_app/vue/home/message/AudioPlayerWidget.dart';
import 'package:discution_app/vue/widget/PhotoView.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FileCustomMessage extends StatelessWidget{
  FileModel file;
  late bool _isImage;
  late bool _isVideo;
  late bool _isaudio;
  FileCustomMessage(this.file){
    _isImage = file.name.toLowerCase().endsWith('.png') ||
        file.name.toLowerCase().endsWith('.jpg') ||
        file.name.toLowerCase().endsWith('.jpeg') ||
        file.name.toLowerCase().endsWith('.gif');
    _isVideo = file.name.toLowerCase().endsWith('.mp4') || file.name.toLowerCase().endsWith('.avi');
    _isaudio = file.name.toLowerCase().endsWith('.mp3') || file.name.toLowerCase().endsWith('.aac');
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


  Widget videoFileWidget() {
    return Icon(
      Icons.play_circle,
      size: 50,
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
    VideoPlayerController _controller =VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500,
      ),
      child: FractionallySizedBox(
        widthFactor: 0.4, // Pour que l'image occupe la moitié de la largeur disponible
        child: VideoPlayer(_controller),
      ),
    );
  }

  Widget viewFile(FileModel file, bool isImage, bool isVideo, bool isAudio) {
    if (isImage) {
      return imageFileWidget(
          Constant.baseUrlFilesMessages + "/" + file.linkFile);
    } else if (isVideo) {
      return videoFileWidget();
    } else if (isAudio) {
      return audioFileWidget(file);
    } else {
      return genericFileWidget(file);
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onLongPress: () {
          FileGestion.downloadFile(
              Constant.baseUrlFilesMessages + "/" + file.linkFile,
              file.name,
              context);
        },
        onTap: () {
          if (_isImage) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PhotoViewCustom(
                      Constant.baseUrlFilesMessages + "/" + file.linkFile)),
            );
          } else {
            FileGestion.Open(
                Constant.baseUrlFilesMessages + "/" + file.linkFile, file.name);
          }
        },
        child: viewFile(file, _isImage, _isVideo, _isaudio),
      ),
    );
  }
}