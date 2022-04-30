import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final _storage = FirebaseStorage.instance;

  uploadImageToStorage(String childName, Uint8List file, String uid) async {
    final ref = _storage.ref().child(childName).child(uid);
    final uploadTask = ref.putData(
      file,
      SettableMetadata(
        contentType: "image/jpg",
      ),
    );
    final snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
