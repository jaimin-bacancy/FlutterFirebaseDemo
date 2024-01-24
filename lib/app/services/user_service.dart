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

  Future<String> createChatConversion(
      String currentID, String receiverId) async {
    String c1 = "$currentID#$receiverId";
    String c2 = "$receiverId#$currentID";
    CollectionReference conversations =
        FirebaseFirestore.instance.collection(FirebaseConfig.db_conversations);

    final snapshot = await conversations.doc(c1).get();
    String conversationID = c1;
    if (snapshot.exists) {
      conversationID = c1;
    } else {
      final snapshot = await conversations.doc(c2).get();
      if (snapshot.exists) {
        conversationID = c2;
      }
    }

    String user1 = conversationID.split("#").first;
    String user2 = conversationID.split("#").last;

    DocumentReference dRefUser1 =
        FirebaseFirestore.instance.doc("/users/$user1");
    DocumentReference dRefUser2 =
        FirebaseFirestore.instance.doc("/users/$user2");

    final user = <String, dynamic>{
      FirebaseConfig.field_user1: dRefUser1,
      FirebaseConfig.field_user2: dRefUser2,
    };

    await _db
        .collection(FirebaseConfig.db_conversations)
        .doc(conversationID)
        .update(user);

    return conversationID;
  }

  Future<void> inviteForChat(String currentID, String conversationID) async {
    DocumentReference dRefRequestedBy =
        FirebaseFirestore.instance.doc("/users/$currentID");

    final user = <String, dynamic>{
      FirebaseConfig.field_requestedBy: dRefRequestedBy,
      FirebaseConfig.field_requestAccepted: false,
    };

    await _db
        .collection(FirebaseConfig.db_conversations)
        .doc(conversationID)
        .update(user);
  }

  void updateUser() async {}
}
