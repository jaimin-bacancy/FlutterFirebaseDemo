// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBAuth;
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/data/models/conversation.dart';
import 'package:firebase_demo/app/data/models/follow_request.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:firebase_demo/app/services/message_service.dart';
import 'package:firebase_demo/app/services/user_service.dart';
import 'package:firebase_demo/app/widgets/form_button.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {super.key,
      required this.conversation,
      required this.requested,
      required this.followRequest});
  Conversation conversation;
  FollowRequest followRequest;
  bool requested;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatUser sender = ChatUser(id: "1", firstName: "");
  DocumentReference? _documentReference;

  @override
  void initState() {
    super.initState();

    setCurrentUser();
  }

  void setCurrentUser() async {
    FBAuth.User? senderData = await AuthService(context).getCurrentUser();
    setState(() {
      sender = ChatUser(id: senderData!.uid, firstName: senderData.displayName);
      _documentReference =
          FirebaseFirestore.instance.doc("/users/${senderData.uid}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.name)),
      body: (widget.requested &&
              widget.followRequest.requestAccepted != null &&
              widget.followRequest.requestAccepted!)
          ? StreamBuilder<dynamic>(
              stream: MessageService(context)
                  .getMessagesStream(widget.conversation.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data?.docs;
                  List<ChatMessage> messageWidgets = [];
                  for (var element in messages) {
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

                      MessageService(context).saveMessage(
                          widget.conversation.id, message.text, from);
                    },
                    messages: messageWidgets,
                  );
                } else {
                  return const Column(
                    children: [
                      CircularProgressIndicator(
                        color: Colors.deepPurple,
                      )
                    ],
                  );
                }
              })
          : (widget.followRequest.requestedBy != _documentReference &&
                  widget.requested &&
                  widget.followRequest.requestAccepted != null &&
                  !widget.followRequest.requestAccepted!)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("${widget.conversation.name} invited for chat",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: FormButton(
                              label: "Accept",
                              onButtonPress: () {
                                UserService(context).inviteForChat(
                                    sender.id, widget.conversation.id);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: FormButton(
                              label: "Reject",
                              onButtonPress: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Invite ${widget.conversation.name} to chat",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: FormButton(
                              label: (widget.requested &&
                                      (widget.followRequest.requestAccepted !=
                                              null &&
                                          !widget.followRequest
                                              .requestAccepted!) &&
                                      widget.followRequest.requestedBy ==
                                          _documentReference)
                                  ? "Requested"
                                  : "Send Request",
                              onButtonPress: () {
                                UserService(context).inviteForChat(
                                    sender.id, widget.conversation.id);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: FormButton(
                              label: "Go back",
                              onButtonPress: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
    );
  }
}
