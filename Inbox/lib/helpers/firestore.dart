import 'package:cloud_firestore/cloud_firestore.dart';

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
      String messageId, String anotherId) async {
    await FireStore.deleteMessage(senderId, receiverId, anotherId);
    await FireStore.deleteMessage(receiverId, senderId, messageId);
  }
}
