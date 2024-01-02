// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  BuildContext context;

  UserService(this.context);

  Future<bool> checkAlreadyExist(String uid) async {
    final docRef = _db.collection(FirebaseConfig.db_users).doc(uid);
    final snapshot = await docRef.get();
    return snapshot.exists;
  }

  Future<bool> createUser(
    String uid,
    String name,
    String email,
  ) async {
    // Create a new user with a name, email and uid
    final user = <String, dynamic>{
      "uid": uid,
      "name": name,
      "email": email,
    };

    try {
      _db.collection(FirebaseConfig.db_users).doc(uid).set(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  void updateUser() async {}
}
