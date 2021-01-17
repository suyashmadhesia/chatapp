import 'dart:io';

class DropDownMenu {
  static const String block = 'Block';
  static const String muteChat = 'Mute Chat';

  static const String unBlock = 'Unblock';
  static const String unMute = 'Unmute';

  static const List<String> choices = <String>[
    block,
    muteChat,
  ];

  static const List<String> blockedChoice = <String>[
    unBlock,
    muteChat,
  ];

  static const List<String> bothBlockedAndMuted = <String>[
    unBlock,
    unMute,
  ];

  static const List<String> unMuteChoice = <String>[
    block,
    unMute,
  ];
}


const String MEDIA_PATH = '';

bool isFileExist(String path) {
  return File(path).existsSync();
}

bool isMediaExist(String name) {
  return isFileExist(MEDIA_PATH + name);
}
