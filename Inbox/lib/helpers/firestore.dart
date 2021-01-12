import 'package:cloud_firestore/cloud_firestore.dart';

class FireStore {
  static CollectionReference getCollectionReference(String path) {
    return FirebaseFirestore.instance.collection(path);
  }

  
}
