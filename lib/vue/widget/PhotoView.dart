import 'package:cached_network_image/cached_network_image.dart';
import 'package:Pouic/vue/widget/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewCustom extends StatelessWidget{
  late String url;

  PhotoViewCustom(this.url);

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: CustomAppBar(arrowReturn: true),
        body: PhotoView(
          imageProvider: CachedNetworkImageProvider(url),
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
        ),
      );
  }

}