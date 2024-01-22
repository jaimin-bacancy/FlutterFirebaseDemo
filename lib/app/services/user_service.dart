// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  BuildContext context;

  UserService(this.context);

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

  Future<void> sendFollowRequest(String followerId, String name) async {
    String? currentUserID = await AuthService(context).getCurrentUID();
    await _db
        .collection(FirebaseConfig.db_users)
        .doc(currentUserID)
        .collection(FirebaseConfig.db_followers)
        .doc(followerId)
        .set({FirebaseConfig.field_isApproved: false});

    await _db
        .collection(FirebaseConfig.db_users)
        .doc(followerId)
        .collection(FirebaseConfig.db_followRequests)
        .doc(currentUserID)
        .set({
      FirebaseConfig.field_isApproved: false,
      FirebaseConfig.field_name: name
    });
  }

  Future<void> approveFollowRequest(String followerId) async {
    String? currentUserID = await AuthService(context).getCurrentUID();

    await _db
        .collection(FirebaseConfig.db_users)
        .doc(currentUserID)
        .collection(FirebaseConfig.db_followers)
        .doc(followerId)
        .update({FirebaseConfig.field_isApproved: true});

    await _db
        .collection(FirebaseConfig.db_users)
        .doc(followerId)
        .collection(FirebaseConfig.db_following)
        .doc(currentUserID)
        .set({});
  }

  void updateUser() async {}
}
