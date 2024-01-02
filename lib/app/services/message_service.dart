// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/data/models/user.dart';
import 'package:firebase_demo/app/utils/common_methods.dart';
import 'package:flutter/material.dart';

class MessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  BuildContext context;

  MessageService(this.context);

  Future<List<ChatMessage>> getMessages(int offset) async {
    int limit = 20;
    List<User> listData = [];
    try {
      Query<Map<String, dynamic>> first =
          _db.collection(FirebaseConfig.db_users).orderBy("name").limit(limit);

      QuerySnapshot<Map<String, dynamic>> documentSnapshots = await first.get();
      List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
          documentSnapshots.docs;

      for (var element in data) {
        User newUser = User.fromJson(element.data());
        listData.add(newUser);
      }

      return listData;

      // Get the last visible document
      DocumentSnapshot lastVisible =
          documentSnapshots.docs[documentSnapshots.size - 1];

      // // Construct a new query starting at this document,
      // // get the next users.
      Query<Map<String, dynamic>> next = _db
          .collection(FirebaseConfig.db_users)
          .orderBy("name")
          .startAfterDocument(lastVisible)
          .limit(limit);
    } catch (e) {
      CommonMethods.showToast(context, e.toString());

      throw Exception(e);
    }
  }
}
