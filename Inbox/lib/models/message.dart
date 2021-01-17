import 'dart:io';
import 'dart:typed_data';

import 'package:Inbox/helpers/file_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';

class Asset {
  String thumbnail;
  String url;
  String contentType;
  String name;
  bool isAssetPresentInDevice;
  File file;
  Uint8List thumbnailFile;
  UploadTask task;
  double progrss;
  Asset(
      {this.name,
      this.thumbnail = "",
      this.isAssetPresentInDevice = false,
      this.contentType,
      this.file,
      this.task,
      this.thumbnailFile,
      this.progrss,
      this.url}) {
    if (this.name != null && this.contentType != null) {
      FileManager.isMediaExist(name, getContent())
          .then((value) => {isAssetPresentInDevice = value});
    }
  }

  Asset.fromJson(Map<String, String> json) {
    thumbnail = json["thumbnail"];
    url = json["url"];
    contentType = json["contentType"];
    name = json["name"];
  }

  void updateProgress(double pg) {
    this.progrss = pg;
  }

  static String _getContent(String content) {
    var splitted = content.split("/");
    return splitted[splitted.length - 1];
  }

  String getContent() {
    return Asset._getContent(contentType);
  }

  String generateName() {
    var generated = randomAlphaNumeric(18);
    var content = getContent();
    return '$content-$generated';
  }

  void setNameGenerated() {
    this.name = this.generateName();
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "thumbnail": thumbnail,
      "ulr": url,
      "contentType": contentType
    };
  }

  @override
  String toString() {
    return "Asset(name:$name, contentType: $contentType)";
  }
}

class Message {
  String anotherId;
  String sender;
  String messageId;
  DateTime timestamp;
  List<Asset> assets;
  String message;

  static const Map<int, String> months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sept',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec'
  };

  Message(
      {this.anotherId,
      this.sender,
      this.assets = const [],
      this.timestamp,
      this.message,
      this.messageId});

  Message.fromJson(Map<String, dynamic> json) {
    anotherId = json['anotherId'];
    sender = json["sender"];
    messageId = json["messageId"];
    timestamp = json["timestamp"].toDate();
    message = json.containsKey("message") ? json["message"] : "";
    assets = json.containsKey("assets")
        ? (json["assets"]).map((value) => Asset.fromJson(value))
        : [];
  }

  String getDateFormat() {
    var now = DateTime.now();
    var time = timestamp.hour.toString() + ":" + timestamp.minute.toString();
    if (now.day == timestamp.day &&
        now.month == timestamp.month &&
        now.year == timestamp.year) {
      return 'Today | $time';
    }
    return '${timestamp.day} ${months[timestamp.month]} | $time';
  }
}
