import 'constant.dart' show isMediaExist;

class Asset {
  String thumbnail;
  String url;
  String contentType;
  String name;
  bool isAssetPresentInDevice;

  Asset(
      {this.name,
      this.thumbnail,
      this.isAssetPresentInDevice = false,
      this.contentType,
      this.url}) {
    this.isAssetPresentInDevice = isMediaExist(name);
  }

  Asset.fromJson(Map<String, String> json) {
    thumbnail = json["thumbnail"];
    url = json["url"];
    contentType = json["contentType"];
    name = json["name"];
  }
}

class Message {
  bool visibility;
  String sender;
  String messageId;
  DateTime timestamp;
  List<Asset> assets;
  String message;
  String avatar;

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
// TODO ther is no another id in db it was removed only given fields are => correct the json field
/* assets =[]
avatar =''
message = ''
messageId= ''
sender = ''//sneder id
timeStamp = ''
visibility */
  Message(
      {this.visibility,
      this.avatar,
      this.sender,
      this.assets = const [],
      this.timestamp,
      this.message,
      this.messageId});

  Message.fromJson(Map<String, dynamic> json) {
    visibility = json['visbility'];
    sender = json["sender"];
    messageId = json["messageId"];
    timestamp = json["timestamp"].toDate();
    message = json.containsKey("message") ? json["message"] : "";
    assets = json.containsKey("assets")
        ? (json["assets"]).map((value) => Asset.fromJson(value))
        : [];
    avatar = json['avatar'];
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
