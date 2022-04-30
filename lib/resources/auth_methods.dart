import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:twich_clone/models/user.dart' as model;
import 'package:twich_clone/providers/user_provider.dart';
import 'package:twich_clone/utils/utils.dart';

class AuthMethods {
  final _userRef = FirebaseFirestore.instance.collection("users");
  final _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
    if (uid != null) {
      final snap = await _userRef.doc(uid).get();
      return snap.data();
    }
    return null;
  }

  Future<bool> signUpUser(
    String email,
    String username,
    String password,
    BuildContext context,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        final user = model.User(
          uid: cred.user!.uid,
          username: username.trim(),
          email: email.trim(),
        );

        await _userRef.doc(user.uid).set(user.toMap());
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      showSnackBar(context, e.message!);
      return false;
    }
  }

  Future<bool> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(
          model.User.fromMap(
            await getCurrentUser(cred.user!.uid) ?? {},
          ),
        );
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      showSnackBar(context, e.message!);
      return false;
    }
  }
}
