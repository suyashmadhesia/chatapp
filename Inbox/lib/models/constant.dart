import 'dart:io';

class DropDownMenu {
  static const String block = 'Block';
  static const String clearChat = 'Clear Chat';

  static const String unBlock = 'Unblock';

  static const List<String> choices = <String>[
    block,
    clearChat,
  ];

  static const List<String> blockedChoice = <String>[
    unBlock,
    clearChat,
  ];
}

const String MEDIA_PATH = '';

bool isFileExist(String path) {
  return File(path).existsSync();
}

bool isMediaExist(String name) {
  return isFileExist(MEDIA_PATH + name);
}
