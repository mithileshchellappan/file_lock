
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share/share.dart';

class PdfView extends StatefulWidget {
  String pdfPath;
  PdfView(this.pdfPath);
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('PDF Viewer'),
          centerTitle: true,
          actions: [
            FlatButton(
              child: Icon(Icons.share),
              onPressed: () async {
                await Share.shareFiles([widget.pdfPath],text:'Sharing Locked Pdf');
              },
            )
          ],
        ),
        body: PDFView(
          filePath: widget.pdfPath,
          enableSwipe: true,
        ));
  }
}
