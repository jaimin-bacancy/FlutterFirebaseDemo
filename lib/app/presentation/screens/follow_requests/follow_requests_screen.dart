import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/data/models/conversation.dart';
import 'package:firebase_demo/app/data/models/follow_request.dart';
import 'package:firebase_demo/app/data/models/user.dart';
import 'package:firebase_demo/app/presentation/screens/chat/chat_screen.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:firebase_demo/app/services/user_service.dart';
import 'package:flutter/material.dart';

class FollowRequestsScreen extends StatefulWidget {
  const FollowRequestsScreen({super.key});

  @override
  State<FollowRequestsScreen> createState() => _FollowRequestsScreenState();
}

class _FollowRequestsScreenState extends State<FollowRequestsScreen> {
  final bool _isLoading = false;
  List<User> users = [];
  String? currentUserID;
  Stream? stream;

  @override
  void initState() {
    super.initState();

    initMessages();
  }

  void initMessages() async {
    String? currentID = await AuthService(context).getCurrentUID();

    setState(() {
      currentUserID = currentID;
    });

    if (currentID != null) {
      stream = FirebaseFirestore.instance
          .collection(FirebaseConfig.db_users)
          .where(FirebaseConfig.field_uid, isNotEqualTo: currentID)
          .snapshots();
    }
  }

  void onItemTap(
      Conversation conversation, bool requested, FollowRequest followRequest) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatScreen(
          conversation: conversation,
          requested: requested,
          followRequest: followRequest);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(StringConfig.usersText)),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: HomeList(
                  users: users,
                  stream: stream,
                  isLoading: _isLoading,
                  onItemTap: onItemTap,
                  currentUserID: currentUserID),
            )
          ],
        ));
  }
}

class HomeList extends StatefulWidget {
  HomeList(
      {super.key,
      required this.users,
      required this.stream,
      required this.isLoading,
      required this.onItemTap,
      required this.currentUserID});

  final Function onItemTap;
  final bool isLoading;
  final List<User> users;
  String? currentUserID = "";
  Stream? stream;

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.deepPurple,
      strokeWidth: 2.0,
      onRefresh: () async {
        return;
      },
      child: StreamBuilder(
          stream: widget.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            var users = snapshot.data!.docs;

            return ListView.builder(
              controller: scrollController,
              itemCount: users.length,
              itemBuilder: (context, index) {
                User newUser = User.fromJson(users[index].data());

                return UserListItem(
                    user: newUser,
                    index: index,
                    isApproved: false,
                    onItemTap: () async {
                      String conversationId = await UserService(context)
                          .createChatConversion(
                              widget.currentUserID!, newUser.uid);

                      DocumentSnapshot documentSnapshot =
                          await FirebaseFirestore.instance
                              .collection(FirebaseConfig.db_conversations)
                              .doc(conversationId)
                              .get();

                      Map<String, dynamic> newData =
                          documentSnapshot.data() as Map<String, dynamic>;
                      bool requested = false;
                      bool requestAccepted = false;
                      DocumentReference? requestedBy;
                      if (newData
                          .containsKey(FirebaseConfig.field_requestAccepted)) {
                        requested = true;
                        requestAccepted =
                            newData[FirebaseConfig.field_requestAccepted];
                        requestedBy = newData[FirebaseConfig.field_requestedBy];
                      } else {
                        requested = false;
                      }

                      Conversation conversation = Conversation(
                          name: newUser.name,
                          id: conversationId,
                          receiverId: newUser.uid,
                          lastMessage: "",
                          markAsRead: false,
                          isReceiver: true);

                      FollowRequest followRequest = FollowRequest(
                          user1: newData[FirebaseConfig.field_user1],
                          user2: newData[FirebaseConfig.field_user2],
                          requestedBy: requestedBy,
                          requestAccepted: requestAccepted);

                      widget.onItemTap(conversation, requested, followRequest);
                    });
              },
            );
          }),
    );
  }
}

class UserListItem extends StatelessWidget {
  const UserListItem(
      {super.key,
      required this.user,
      required this.index,
      required this.isApproved,
      required this.onItemTap});

  final User user;
  final int index;
  final Function onItemTap;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () => {onItemTap()},
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                    Text(user.email,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.black))
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
