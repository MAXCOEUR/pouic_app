import 'package:discution_app/outil/Constant.dart';
import 'package:flutter/material.dart';

class EmojiList extends StatefulWidget {
  final List<String> popularEmojis;
  final Function(String) onEmojiSelected;

  EmojiList({
    required this.popularEmojis,
    required this.onEmojiSelected,
  });

  @override
  _EmojiListState createState() => _EmojiListState();
}

class _EmojiListState extends State<EmojiList> {
  bool showMoreEmojis = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < (showMoreEmojis ? widget.popularEmojis.length : 4); i++)
              Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background, // Couleur du cercle
                  shape: BoxShape.circle, // Forme du cercle
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.onEmojiSelected(widget.popularEmojis[i]);
                    Navigator.of(context).pop();
                  },
                  child: Text(widget.popularEmojis[i],style: TextStyle(fontSize: SizeFont.h1)),
                ),
              ),
            if (!showMoreEmojis)
              Container(
                padding: EdgeInsets.all(7),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showMoreEmojis = true;
                    });
                  },
                  child: Text("+",style: TextStyle(fontSize: SizeFont.h1)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
