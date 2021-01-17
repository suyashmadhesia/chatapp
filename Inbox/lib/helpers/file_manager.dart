import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
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
      FileType fileType = FileType.audio,
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

  static Future<bool> isMediaExist(String name, String ext) async {
    return isFileExist(
        (await FileManager.getDirPath()) + '/media/images/$name.$ext');
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
}
