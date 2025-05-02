import 'package:audioplayers/audioplayers.dart';
import 'package:pouic/Model/FileModel.dart';
import 'package:pouic/outil/Constant.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final FileModel file;

  AudioPlayerWidget({required this.file});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration();
  Duration _position = Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _position = position;

          if (_duration.inMilliseconds!= Duration().inMilliseconds && _position >= _duration) {
            print("end");
            _playPause();
          }
        });
      }
    });
  }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play(UrlSource(
          Constant.baseUrlFilesMessages + "/" + widget.file.linkFile));
    }
    if (mounted) {
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child:Column(
      children: [
        Row(
          children: <Widget>[
            Container(
              child: Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (double value) {
                    setState(() {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    });
                  },
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _playPause,
            ),
          ],
        ),SizedBox(width: SizeMarginPading.h3),
        Text(
            widget.file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    ),);
  }

  @override
  void dispose() {
    super.dispose();
    //_audioPlayer.release();
    //_audioPlayer.dispose();
  }
}
