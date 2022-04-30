import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twich_clone/models/livestream.dart';
import 'package:twich_clone/providers/user_provider.dart';
import 'package:twich_clone/resources/storage_methods.dart';
import 'package:twich_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FirestoreMhetods {
  final _firestore = FirebaseFirestore.instance;
  final _storageMethdos = StorageMethods();

  Future<String> starLiveStream(
      BuildContext context, String title, Uint8List? image) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    String chaennelId = "";
    try {
      if (title.isNotEmpty && image != null) {
        final r = await _firestore
            .collection("livestream")
            .doc("${user.user.uid}${user.user.username}")
            .get();
        if (!r.exists) {
          String thumbnailUrl = await _storageMethdos.uploadImageToStorage(
              "livestream-thumbnails", image, user.user.uid);

          chaennelId = "${user.user.uid}${user.user.username}";
          final liveStream = LiveStream(
            title: title,
            image: thumbnailUrl,
            uid: user.user.uid,
            username: user.user.username,
            startedAt: DateTime.now(),
            viewers: 0,
            channelId: chaennelId,
          );
          await _firestore
              .collection("livestream")
              .doc(chaennelId)
              .set(liveStream.toMap());
        } else {
          showSnackBar(context, "Two liveStream no working");
        }
      } else {
        showSnackBar(context, "Please enter all the fields");
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }

    return chaennelId;
  }

  Future<void> endLiveStream(String chaennelId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection("livestream")
          .doc(chaennelId)
          .collection("comments")
          .get();

      for (var i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection("livestream")
            .doc(chaennelId)
            .collection("comments")
            .doc((snap.docs[i].data()! as dynamic)["commenId"])
            .delete();
      }

      await _firestore.collection("livestream").doc(chaennelId).delete();
    } catch (e) {
      debugPrint("error" + e.toString());
    }
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firestore
          .collection("livestream")
          .doc(id)
          .update({"viewers": FieldValue.increment(isIncrease ? 1 : -1)});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> chat(String text, String id, BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false);
    try {
      String commentId = const Uuid().v1();
      await _firestore
          .collection("livestream")
          .doc(id)
          .collection("comments")
          .doc(commentId)
          .set({
        "commenId": commentId,
        "message": text,
        "username": user.user.username,
        "uid": user.user.uid,
        "createdAt": DateTime.now(),
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }
}
