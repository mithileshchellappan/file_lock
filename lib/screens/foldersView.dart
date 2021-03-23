import 'dart:io';
import 'dart:typed_data';
import 'package:aes_crypt/aes_crypt.dart';

import 'package:file_lock/screens/imageView.dart';
import 'package:file_lock/screens/pdfViewe.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mime/mime.dart';
import 'package:multi_select_item/multi_select_item.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';

List filers = new List();
List<Directory> directory;
Directory dir = Directory('/storage/emulated/0');
Directory docuDir;
String openPassword = '';
ScrollController scrollController = ScrollController();

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

final controller = new MultiSelectController();

class _FolderViewState extends State<FolderView> {
  bool isExpanded = true;
  var openBox;

  @override
  void initState() {
    openHiveBox();
    var box = Hive.box('box');
    controller.disableEditingWhenNoneSelected = true;
    controller.set(filers.length);

    listOfFiles();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openHiveBox() async {
    openBox = Hive.box('box');
  }

  void listOfFiles() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory docuDir2 = await getExternalStorageDirectory();
    docuDir = Directory('${docuDir2.path}/files');
    if (!await docuDir.exists()) {
      print(docuDir);
      docuDir = await createDir();
    }
    setState(() {
      filers = docuDir.listSync();
    });
  }

  TextEditingController textEditingController = TextEditingController();
  String password = '';
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                // addFile();
                String result;
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        
      );

      result = await FlutterDocumentPicker.openDocument(params: params);
      print(result);
              },
              label: Text('Add New File'),
              icon: Icon(Icons.add),
              isExtended: true,
            ),
            body: filers.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Image.asset('Capture.gif'),
                        Text('There is nothing over here!',style:TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                      ]))
                : HomeBody(),
            appBar: AppBar(
                actions: [
                  TextButton(
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        filers = docuDir.listSync();
                      });
                    },
                  )
                ],
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text('Your Files'))),
        onWillPop: () async => false);
  }
  

  void addFile() async {
    var crypt = AesCrypt('pass');
    crypt.setOverwriteMode(AesCryptOwMode.on);
    if (!await docuDir.exists()) {
      docuDir = await createDir();
    }
    String result = await FilesystemPicker.open(
        title: 'Choose file to encrypt',
        context: context,
        rootDirectory: dir,
        allowedExtensions: ['.jpg', '.png', '.pdf', '.txt'],
        fsType: FilesystemType.file);
    if (result != null) {
      print(result);

      Alert(
          context: context,
          title: 'Set Password',
          buttons: [
            DialogButton(
                child: Text('Submit', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (password != '') {
                    File file = File(result);
                    String rootDir = file.parent.path;
                    print('root dir $rootDir');
                    String fileName = file.path.split('/').last;
                    print(fileName);
                    //crypt.encryptFileSync(result,'${docuDir.toString()}/$fileName');
                    setState(() {
                      isLoading = true;
                    });
                    File file2 = await File('$rootDir/$fileName')
                        .rename('${docuDir.path}/$fileName');

                    var box = Hive.box('box');
                    box.put('$fileName.aes', password);
                    print('fn $fileName');
                    print(box.get(fileName));

                    crypt.encryptFileSync('${docuDir.path}/$fileName');
                    await File('${docuDir.path}/$fileName').delete();

                    setState(() {
                      isLoading = false;
                      filers = docuDir.listSync();
                    });
                    textEditingController.clear();
                    Navigator.pop(context);
                  }
                })
          ],
          content: Column(
            children: [
              TextField(
                controller: textEditingController,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
            ],
          )).show();
    }
  }

  Future<Directory> createDir() async {
    Directory docDir = await docuDir.create(recursive: true);
    return docDir;
  }
}

class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Expanded(
            child: GridView.builder(
                controller: scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: filers.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: fileView(
                      filers[index].path.toString().split('/').last,
                      filers[index].path,
                      context,
                    ),
                  );
                }))
      ],
    ));
  }

  void deleter(String pathToDel) {
    File(pathToDel).delete();
    setState(() {
      filers = docuDir.listSync();
    });
  }

  Widget fileView(String title, String path, BuildContext context,
      {String fileType}) {
    fileType = title.split('.').removeAt(1);
    var crypt = AesCrypt('pass');
    return Container(
        decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20)),
        child: Expanded(
          child: FlatButton(
            onLongPress: () {
              Alert(
                type: AlertType.warning,
                context: context,
                title: 'Delete file?',
                content: Text(
                    'Are you sure you want to delete? There is no way to recover it'),
                buttons: [
                  DialogButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onPressed: () {
                      File file = File(path);
                      file.delete();
                      setState(() {
                        filers = docuDir.listSync();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  DialogButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ).show();
            },
            onPressed: () async {
              var box = Hive.box('box');
              String pass = box.get(title);
              Alert(
                  context: context,
                  title: 'Enter password to open file',
                  buttons: [
                    DialogButton(
                        child:
                            Text('OPEN', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          if (openPassword == pass || openPassword == 'null') {
                            var aes = AesCrypt('pass');
                            aes.setOverwriteMode(AesCryptOwMode.on);
                            String ext = '${title.split('.').last}';
                            print(ext);
                            if (ext == 'aes') {
                              print('inside if');
                              String openPath = aes.decryptFileSync(path);
                              String type = openPath.split('/').last;
                              String type2 = type.split('.').last;
                              print(type2 + 'type');
                              if (type2 == 'png' ||
                                  type2 == 'jpeg' ||
                                  type2 == 'jpg') {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ImageView(openPath))).then((value) {
                                  deleter(openPath);
                                  setState(() {
                                    filers = docuDir.listSync();
                                  });
                                });
                              } else if (type2 == 'pdf') {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PdfView(openPath))).then((value) {
                                  deleter(openPath);
                                  setState(() {
                                    filers = docuDir.listSync();
                                  });
                                });
                              }
                            }
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Wrong Password'),
                            ));
                            Navigator.pop(context);
                          }
                        })
                  ],
                  content: Column(
                    children: [
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            openPassword = val;
                          });
                        },
                      ),
                    ],
                  )).show();

              // var mimeRet = lookupMimeType(path);
              // print(mimeRet);
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Builder(builder: (context) {
                  if (fileType == 'pdf') {
                    return GridTile(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 80.0,
                      ),
                      footer: Center(child: Text(title.split('.').first)),
                    );
                  } else {
                    return GridTile(
                      child: Icon(
                        Icons.photo,
                        size: 80.0,
                      ),
                      footer: Center(child: Text(title.split('.').first)),
                    );
                  }
                })),
          ),
        ));
  }
}
