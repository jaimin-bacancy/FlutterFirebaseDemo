// ignore_for_file: must_be_immutable

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBAuth;
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/data/models/user.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.user});
  User user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser currentUser = ChatUser(id: "1", firstName: "");

  @override
  void initState() {
    super.initState();

    setCurrentUser();
  }

  void fetchMyUsers(String searchText, int offset) {}

  void setCurrentUser() async {
    FBAuth.User? user = await AuthService(context).getCurrentUser();
    setState(() {
      currentUser = ChatUser(id: user!.uid, firstName: user.displayName);
    });
  }

  List<ChatMessage> messages = <ChatMessage>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConfig.chatText)),
      body: DashChat(
        currentUser: currentUser,
        onSend: (ChatMessage message) {
          setState(() {
            messages.insert(0, message);
          });
        },
        messages: messages,
      ),
    );
  }
}
