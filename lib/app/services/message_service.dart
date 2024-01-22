// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:flutter/material.dart';

class MessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  BuildContext context;

  MessageService(this.context);

  Stream getMessagesStream(String conversationId) {
    return FirebaseFirestore.instance
        .collection(FirebaseConfig.db_conversations)
        .doc(conversationId)
        .collection(FirebaseConfig.db_chat)
        .orderBy(FirebaseConfig.field_createdAt, descending: true)
        .snapshots();
  }

  void saveMessage(String conversationID, String text, int from) async {
    await _db
        .collection(FirebaseConfig.db_conversations)
        .doc(conversationID)
        .collection(FirebaseConfig.db_chat)
        .add({
      FirebaseConfig.field_from: from,
      FirebaseConfig.field_text: text,
      FirebaseConfig.field_createdAt: FieldValue.serverTimestamp(),
      FirebaseConfig.field_markAsRead: false,
    });
  }

  void setMarkAsRead(String conversationID, int from, callback) async {
    await _db
        .collection(FirebaseConfig.db_conversations)
        .doc(conversationID)
        .collection(FirebaseConfig.db_chat)
        .where(FirebaseConfig.field_markAsRead, isNotEqualTo: true)
        .where(FirebaseConfig.field_from, isEqualTo: from)
        .get()
        .then((value) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in value.docs) {
        final documentBody = <String, dynamic>{
          FirebaseConfig.field_markAsRead: true,
        };

        final docRef = FirebaseFirestore.instance
            .collection(FirebaseConfig.db_conversations)
            .doc(conversationID)
            .collection(FirebaseConfig.db_chat)
            .doc(doc.id);
        batch.update(docRef, documentBody);
      }

      batch.commit().then((value) {
        if (callback != null) {
          callback();
        }
      });
    });
  }
}
