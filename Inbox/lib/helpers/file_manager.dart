import 'dart:io';
import 'dart:typed_data';
import 'package:Inbox/models/message.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as pathModule;
import 'package:path_provider/path_provider.dart';
import 'package:Inbox/models/constant.dart' show isFileExist;
import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:permission_handler/permission_handler.dart';

class FileManager {
  static Future<String> getDirPath({StorageDirectory type}) async {
    Directory dir = ((Platform.isAndroid)
        ? (await getExternalStorageDirectories(type: type))[0]
        : await getApplicationDocumentsDirectory());
    // print(dir.path);
    // if (Platform.isAndroid) {
    //   while (true) {
    //     if (!dir.path.contains("Android")) {
    //       break;
    //     } else {
    //       dir = dir.parent;
    //     }
    //   }
    // }
    String path = dir.path;
    Directory appDir = Directory('${path}/media');
    if (!await appDir.exists()) {
      appDir.create(recursive: true);
    }
    return appDir.path;
  }

  static Future<Uint8List> compressImage(File file, {int quality = 10}) async {
    /// Compress image upto 30%
    return await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: quality,
    );
  }

  // Pick Assets
  static Future<List<File>> pickFiles(
      {bool allowMultiple = true,
      FileType fileType = FileType.any,
      List<String> allowedExtensions = const []}) async {
    FilePickerResult results = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        type: fileType);
    if (results != null) {
      return results.paths.map((path) => File(path)).toList();
    } else {
      return [];
    }
  }

  static Future<File> pickFileUsingPath(String name) async {
    if (await FileManager.isMediaExist(name)) {
      return File((await FileManager.getDirPath()) + '/media/$name');
    }
  }

  static Future<String> getFileName(String name) async {
    String path = await FileManager.getDirPath();
    return path + '/media/$name';
  }

  static Future<bool> isMediaExist(String name) async {
    return isFileExist((await FileManager.getFileName(name)));
  }

  static String getExtension(File file) {
    return pathModule.extension(file.path).replaceFirst(".", "");
  }

  static bool _isImage(String ext) {
    const imagesExtensions = ['png', 'apng', 'jpg', 'jpeg', 'ico'];
    return imagesExtensions.contains(ext);
  }

  static bool isImage(File file) {
    final ext = FileManager.getExtension(file);
    return FileManager._isImage(ext);
  }

  static bool _isVideo(String ext) {
    const videoExtensions = [
      'mp4',
      'mov',
      'wmv',
      'flv',
      'avi',
      'avchd',
      'webm',
      'mkv'
    ];
    return videoExtensions.contains(ext);
  }

  static bool isVideo(File file) {
    final ext = FileManager.getExtension(file);
    return FileManager._isVideo(ext);
  }

  static String getMimeType(File file) {
    return lookupMimeType(file.path);
  }

  static Future<File> downloadFile(String url, String fileName) async {
    // var request = await HttpClient().getUrl(Uri.parse(url));
    // var response = await request.close();
    // var bytes = await consolidateHttpClientResponseBytes(response);
    var dir = await FileManager.getDirPath();
    // var mediaDir =
    //     await new Directory('${dir.path}/Inbox/media').create(recursive: true);
    // print(mediaDir.path);
    print('did it againa');
    await Dio().download(url, '${dir}/$fileName');
    return File('${dir}/$fileName');
  }

  static Future<void> copyFile(Asset asset) async {
    String newPath = await FileManager.getDirPath();
    newPath += '/media/sent';
    Directory dir = Directory(newPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    File file = File('${dir.path}/${asset.name}');
    await file.writeAsBytes(await asset.file.readAsBytes());
    // await file.writeAsBytes(await asset.file.readAsBytes());
  }

  static Future<List<File>> pickMediaFile() async {
    List<String> exts = [
      'png',
      'apng',
      'jpg',
      'jpeg',
      'ico',
      'mp4',
      'mov',
      'wmv',
      'flv',
      'avi',
      'avchd',
      'webm',
      'mkv'
    ];
    List<File> pickedFiles = await FileManager.pickFiles(
        allowMultiple: true,
        allowedExtensions: exts,
        fileType: FileType.custom);
    return pickedFiles;
  }
}
