import 'dart:io';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  String image;
  ImageView(this.image);
  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title:Text('Image Viewer'),centerTitle: true,actions: [
            FlatButton(
              child: Icon(Icons.share),
              onPressed: () async {
                await Share.shareFiles([widget.image],text:'Sharing Locked Image');
              },
            )
          ],),
          body: Container(
          child: PhotoView(imageProvider: FileImage(File(widget.image))),
      ),
    );
  }
}