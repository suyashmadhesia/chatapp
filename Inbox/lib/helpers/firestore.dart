import 'dart:typed_data';

import 'package:Inbox/components/message_bubble.dart';
import 'package:Inbox/helpers/file_manager.dart';
import 'package:Inbox/models/message.dart';
import 'package:Inbox/state/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FireStore {
  static CollectionReference getCollectionReference(String path) {
    return FirebaseFirestore.instance.collection(path);
  }

  static Future<void> deleteMessage(
      // This function will delete the message from receivers db
      String senderId,
      String receiverId,
      String messageId) async {
    var refReceiver = FireStore.getCollectionReference(
        'users/$receiverId/friends/$senderId/messages');
    await refReceiver.doc(messageId).delete();
  }

  static Future<void> unsendMessage(String senderId, String receiverId,
      String messageIdOnSender, String messageIdOnReceiver) async {
    await FireStore.deleteMessage(senderId, receiverId, messageIdOnReceiver);
    await FireStore.deleteMessage(receiverId, senderId, messageIdOnSender);
  }

  static Future<void> sendMessage(
      {String userId,
      String receiverId,
      String message,
      String avatar,
      List<Asset> assets = const [],
      String userUniqueMessageId}) async {
    // print(
    //     '$userId, $receiverId, $message, $avatar, $assets, $userUniqueMessageId');
    String messageCollectionPath = 'messages/$userUniqueMessageId/conversation';
    final messageDocument =
        await FirebaseFirestore.instance.collection(messageCollectionPath).add({
      'sender': userId,
      'message': message,
      'timestamp': DateTime.now(),
      'messageId': '',
      'assets': assets.map((e) => e.toJson()).toList(),
      'visibility': true,
      'avatar': avatar == null ? '' : avatar,
    });
    final String messageId = messageDocument.id;
    await FirebaseFirestore.instance
        .collection(messageCollectionPath)
        .doc(messageId)
        .update({
      'messageId': messageId,
    });
    final sendersMessageRefs = FirebaseFirestore.instance;
    sendersMessageRefs
        .collection('users/' + receiverId + '/friends')
        .doc(userId)
        .update({
      'messageAt': DateTime.now(),
      'lastMessage': message,
      'isSeen': false,
    });
    sendersMessageRefs
        .collection('users/' + userId + '/friends')
        .doc(receiverId)
        .update({
      'messageAt': DateTime.now(),
      'lastMessage': message,
      'isSeen': true,
    });
    await sendersMessageRefs
        .collection('users/' + userId + '/friends/' + receiverId + '/messages')
        .doc(messageId)
        .set({
      'messageId': messageId,
      'timestamp': DateTime.now(),
    });
  }

  static Reference getAssetRef(String ref) {
    Reference reference = FirebaseStorage.instance.ref(ref);
    return reference;
  }

  static UploadTask getUploadTask(Reference ref, dynamic file) {
    return ref.putFile(file);
  }

  static UploadTask getUploadTaskUni8List(Reference ref, Uint8List data) {
    return ref.putData(data);
  }

  static Future<Asset> uploadAsset(Asset asset) async {
    final mediaRef = FireStore.getAssetRef('media/${asset.getCompleteName()}');
    if (asset.thumbnailFile != null) {
      final thumbnailRef =
          FireStore.getAssetRef('media/thumb_${asset.getCompleteName()}');
      asset.task =
          FireStore.getUploadTaskUni8List(thumbnailRef, asset.thumbnailFile);
      asset.thumbnail = await FireStore.getDownloadUrl(asset.task);
    }
    asset.task = FireStore.getUploadTask(mediaRef, asset.file);
    asset.url = await FireStore.getDownloadUrl(asset.task);
    FileManager.copyFile(asset);
    return asset;
  }

  static Future<List<Asset>> bulkFutures(
      List<Future<Asset>> futures, Function next) async {
    return await Future.wait(futures);
  }

  static Future<List<Asset>> bulkAssetUpload(List<Asset> assets,
      {Function next}) async {
    return await FireStore.bulkFutures(
        assets.map((e) => FireStore.uploadAsset(e)).toList(), next);
  }

  static Future<String> getDownloadUrl(UploadTask task) async {
    TaskSnapshot snapshot = await task.whenComplete(() => {});
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  static Future<bool> pauseTask(UploadTask task) async {
    return await task.pause();
  }

  static Future<bool> resumeTask(UploadTask task) async {
    return await task.resume();
  }

  static Future<bool> cancelTask(UploadTask task) async {
    return await task.cancel();
  }

  /**
   * The function will receive assets as list with file, contentType and name only not even the thumbnail
   *  The later will upload to storage and feed the data into asset model
   * 
   */
  static Future uploadAssets(
      {String userId,
      String receiverId,
      String message,
      String avatar,
      List<Asset> assets = const [],
      String userUniqueMessageId}) async {
    GlobalState gState = GlobalState();
    MessageBubble bubble = MessageBubble(
      message: message,
      assets: [],
      timestamp: DateTime.now(),
    );
    for (Asset asset in assets) {
      if (asset.contentType.contains("image")) {
        asset.thumbnailFile = await FileManager.compressImage(asset.file);
      } else if (asset.contentType.contains("video")) {
        asset.thumbnailFile = await VideoThumbnail.thumbnailData(
            video: asset.file.path, imageFormat: ImageFormat.JPEG, quality: 10);
      }
      bubble.assets.add(asset);
    }
    gState.setMessage(userId, bubble);
    print(gState.getLastMessage(userId));
    List<Asset> uploadedAssets =
        await FireStore.bulkAssetUpload(gState.getLastMessage(userId));
    bubble.assets = uploadedAssets;
    await FireStore.sendMessage(
        userId: userId,
        receiverId: receiverId,
        message: message,
        assets: uploadedAssets,
        userUniqueMessageId: userUniqueMessageId);
    // Remove message from data
    gState.popMessage(userId, bubble);
  }
}
