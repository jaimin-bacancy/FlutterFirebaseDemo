// ignore_for_file: must_be_immutable

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBAuth;
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/data/models/conversation.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:firebase_demo/app/services/message_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.conversation});
  Conversation conversation;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser sender = ChatUser(id: "1", firstName: "");

  @override
  void initState() {
    super.initState();

    setCurrentUser();
  }

  void setCurrentUser() async {
    FBAuth.User? senderData = await AuthService(context).getCurrentUser();
    setState(() {
      sender = ChatUser(id: senderData!.uid, firstName: senderData.displayName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.name)),
      body: StreamBuilder<dynamic>(
          stream:
              MessageService(context).getMessagesStream(widget.conversation.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final messages = snapshot.data?.docs;
              List<ChatMessage> messageWidgets = [];
              for (var element in messages!) {
                int from = element.data()[FirebaseConfig.field_from];

                String chatId = widget.conversation.id.split("#").first;

                if (from == 0) {
                  chatId = widget.conversation.id.split("#").last;
                }

                ChatMessage newUser = ChatMessage(
                    createdAt: element
                        .data()[FirebaseConfig.field_createdAt]
                        ?.toDate(),
                    user: ChatUser(
                        firstName: widget.conversation.name, id: chatId),
                    text: element.data()[FirebaseConfig.field_text]);

                messageWidgets.add(newUser);
              }

              return DashChat(
                currentUser: sender,
                onSend: (ChatMessage message) {
                  int from = 0;
                  if (widget.conversation.id.split("#").last ==
                      widget.conversation.receiverId) {
                    from = 1;
                  }

                  MessageService(context)
                      .saveMessage(widget.conversation.id, message.text, from);
                },
                messages: messageWidgets,
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                    backgroundColor: Colors.deepPurple),
              );
            }
          }),
    );
  }
}
