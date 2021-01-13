import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as pathModule;

class FileManager {
  // Pick Assets
  static Future<List<File>> pickFiles(
      {bool allowMultiple = true,
      List<String> allowedExtensions = const []}) async {
    FilePickerResult results = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple, allowedExtensions: allowedExtensions);
    if (results != null) {
      return results.paths.map((path) => File(path)).toList();
    } else {
      return [];
    }
  }

  static String getExtension(File file) {
    return pathModule.extension(file.path).replaceFirst(".", "");
  }

  static bool isImage(File file) {
    final ext = FileManager.getExtension(file);
    const imagesExtensions = ['png', 'apng', 'jpg', 'jpeg', 'ico'];
    return imagesExtensions.contains(ext);
  }
}
