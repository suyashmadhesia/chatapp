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

class FileManager {
  static Future<String> getDirPath() async {
    return (await getApplicationDocumentsDirectory()).path;
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
    return ((await FileManager.getDirPath()) + '/media/$name');
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
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    File file = new File(await FileManager.getFileName(fileName));
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> copyFile(Asset asset) async {
    String newPath = await FileManager.getDirPath();
    newPath += '/media/sent/${asset.name}';
    File file = File(newPath);
    await file.writeAsBytes(await asset.file.readAsBytes());
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
