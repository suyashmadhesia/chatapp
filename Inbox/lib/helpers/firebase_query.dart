import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreMessageQuery {
  CollectionReference collectionReference;
  WriteBatch batch;
  StreamController<List<DocumentSnapshot>> controller;
  List<DocumentSnapshot> messages = [];
  bool hasMore = true;
  int documentLimit = 10;
  var lastDocument;

  FireStoreMessageQuery(String collection) {
    collectionReference = FirebaseFirestore.instance.collection(collection);
    batch = FirebaseFirestore.instance.batch();
    controller = StreamController<List<DocumentSnapshot>>();
  }

  // Realtime Message last 25 from beginning

  Stream<List<DocumentSnapshot>> get streamController => controller.stream;

  getMessages(bool isLoading, String currentUserId, String friendId,
      {Function limitExceed,
      Function stopLoading,
      Function startLoading}) async {
    if (!hasMore) {
      limitExceed();
      return;
    }
    if (isLoading) {
      return;
    }
    startLoading();
    List<String> ids = [currentUserId, friendId];
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await collectionReference
          .where("targets", arrayContains: ids)
          .orderBy("timestamp", descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await collectionReference
          .where("targets", arrayContains: ids)
          .orderBy("timestamp", descending: true)
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get();
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

    // Update Seen to every chat not seen
    querySnapshot.docs.forEach((element) {
      messages.add(element);
      if (element["receiver"] == currentUserId &&
          !(element["seen"] as List<String>).contains(currentUserId)) {
        var list = (element["seen"] as List<String>);
        list.add(currentUserId);
        batch.update(element.reference, {"seen": list});
      }
    });

    // Update Seen to Friend
    await FirebaseFirestore.instance
        .collection("users/$currentUserId/friends/$friendId")
        .where("isSeen", isEqualTo: false)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((element) {
                batch.update(element.reference, {"isSeen": true});
              })
            });
    batch.commit();

    controller.sink.add(messages);
    stopLoading();
  }
}

class FireStoreFriendList {
  CollectionReference friendsReference;

  StreamController<List<DocumentSnapshot>> controller;
  List<DocumentSnapshot> friends = [];
  int documentLimit = 10;
  bool hasMore = true;
  var lastDocument;
  final String currentUser;

  FireStoreFriendList(this.currentUser) {
    friendsReference =
        FirebaseFirestore.instance.collection("users/$currentUser/friends");
    controller = StreamController<List<DocumentSnapshot>>();
  }

  getFriends(bool isLoading,
      {Function limitExceed,
      Function stopLoading,
      Function startLoading}) async {
    if (!hasMore) {
      limitExceed();
      return;
    }
    if (!isLoading) {
      return;
    }
    startLoading();
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      // Bring all friends except blocked ones
      querySnapshot = await friendsReference
          .where("isBlocked", isEqualTo: false)
          .orderBy("messageAt", descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await friendsReference
          .where("isBlocked", isEqualTo: false)
          .orderBy("messageAt", descending: true)
          .limit(documentLimit)
          .get();
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }

    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

    friends.addAll(querySnapshot.docs);
    controller.sink.add(querySnapshot.docs);
    stopLoading();
  }
}
