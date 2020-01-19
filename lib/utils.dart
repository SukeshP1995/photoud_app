import 'package:googleapis/drive/v3.dart' as v3;
import 'package:flutter/services.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';

String _randomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(
      length,
          (index){
        return rand.nextInt(33)+89;
      }
  );

  return new String.fromCharCodes(codeUnits);
}

Future<String> createFolder(v3.DriveApi drive, String name, String parent) async {
  v3.File file = await drive.files.create(
    v3.File()
      ..name = name
      ..parents = [parent]
      ..mimeType = 'application/vnd.google-apps.folder'
  );
  return file.id;
}

Future<String> searchFolderID(v3.DriveApi drive, String folderID, String subFolderName) async {
  v3.FileList fileList = await drive.files.list(
    q: '("$folderID" in parents)',
    $fields: "files(id,name)",
  );
  print(fileList.files.map((file) => file.name));
  return fileList.files.where((file) => file.name==subFolderName).toList()[0].id;
}

Future<String> uploadAsset(v3.DriveApi drive, Asset asset, String parent) async {
  String name = _randomString(10);
  ByteData byteData = await asset.getByteData();
  List<int> imageData = byteData.buffer.asUint8List();
  Completer<List<int>> completer = Completer<List<int>>();
  completer.complete(imageData);
  Stream<List<int>> stream = Stream.fromFuture(completer.future);
  v3.File file = v3.File()
    ..name = "$name.jpg"
    ..parents = [parent]
    ..mimeType = 'image/jpeg';
  file = await drive.files.create(file, uploadMedia: v3.Media(stream, imageData.length));
  return file.id;
}

Future<void> downloadAllFilesInFolder(v3.DriveApi drive, String folderID) async {
  v3.FileList fileList = await drive.files.list(
    q: '("$folderID" in parents)',
    $fields: "files(id,name)",
  );
  await Future.wait(fileList.files.map((file) async {
    v3.Media mediaFile = await drive.files.get(file.id, downloadOptions: v3.DownloadOptions.FullMedia);
    print(mediaFile.stream);
    final directory = await DownloadsPathProvider.downloadsDirectory;
    print(directory.path);
    final saveFile = File('${directory.path}/${new DateTime.now().millisecondsSinceEpoch}.jpg');
    List<int> dataStore = [];
    mediaFile.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      saveFile.writeAsBytes(dataStore);
      print("File saved at ${saveFile.path}");
    }, onError: (error) {
      print("Some Error");
    });
    return file;
  }));

}