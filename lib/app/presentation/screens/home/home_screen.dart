import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/data/models/conversation.dart';
import 'package:firebase_demo/app/data/models/user.dart';
import 'package:firebase_demo/app/presentation/screens/chat/chat_screen.dart';
import 'package:firebase_demo/app/presentation/screens/follow_requests/follow_requests_screen.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
import 'package:firebase_demo/app/services/message_service.dart';
import 'package:firebase_demo/app/services/user_service.dart';
import 'package:firebase_demo/app/utils/common_methods.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _isLoading = false;
  List<Conversation> users = [];
  String searchText = "";
  String? currentUserID = "";
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
          .collection(FirebaseConfig.db_conversations)
          .snapshots();

      getAllConversations(currentID);
    }
  }

  Future<void> getAllConversations(String currentID) async {
    // Reference to the conversations collection
    CollectionReference conversations =
        FirebaseFirestore.instance.collection(FirebaseConfig.db_conversations);

    // Get all documents where user Id and user Id exist in the document ID
    QuerySnapshot querySnapshot = await conversations.get();

    // Iterate through the documents and access their data
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      // Access document data using document.data()
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      if (document.id.contains(currentID)) {
        DocumentReference dRef = data[FirebaseConfig.field_user1];
        DocumentReference dRef2 = data[FirebaseConfig.field_user2];
        dRef.get().then((value) async {
          Map<String, dynamic> newData = value.data() as Map<String, dynamic>;
          User user = User.fromJson(newData);
          if (user.uid != currentID) {
            QuerySnapshot qs = await conversations
                .doc(document.id)
                .collection(FirebaseConfig.db_chat)
                .orderBy(FirebaseConfig.field_createdAt, descending: true)
                .limit(1)
                .get();

            Map<String, dynamic> newData =
                qs.docs[0].data() as Map<String, dynamic>;

            String lastMessage = "";
            bool markAsRead = newData[FirebaseConfig.field_markAsRead];
            bool isReceiver = false;
            String receiverId = "";
            if (newData[FirebaseConfig.field_from] == 0) {
              DateTime startTime =
                  newData[FirebaseConfig.field_createdAt]?.toDate();

              lastMessage = CommonMethods.getLookupMessage(
                  startTime, StringConfig.sentText, StringConfig.agoText);
              receiverId = user.uid;
            } else {
              lastMessage = newData[FirebaseConfig.field_text];
              isReceiver = true;
              receiverId = user.uid;
            }

            Conversation conversation = Conversation(
                name: user.name,
                id: document.id,
                lastMessage: lastMessage,
                markAsRead: markAsRead,
                isReceiver: isReceiver,
                receiverId: receiverId);

            users.add(conversation);
            setState(() {});
            return;
          }

          dRef2.get().then((value) async {
            Map<String, dynamic> newData = value.data() as Map<String, dynamic>;
            User user = User.fromJson(newData);
            if (user.uid != currentID) {
              QuerySnapshot qs = await conversations
                  .doc(document.id)
                  .collection(FirebaseConfig.db_chat)
                  .orderBy(FirebaseConfig.field_createdAt, descending: true)
                  .limit(1)
                  .get();

              Map<String, dynamic> newData =
                  qs.docs[0].data() as Map<String, dynamic>;

              String lastMessage = "";
              bool markAsRead = newData[FirebaseConfig.field_markAsRead];
              bool isReceiver = false;
              String receiverId = "";
              if (newData[FirebaseConfig.field_from] == 1) {
                DateTime startTime =
                    newData[FirebaseConfig.field_createdAt]?.toDate();

                lastMessage = CommonMethods.getLookupMessage(
                    startTime, StringConfig.sentText, StringConfig.agoText);
                receiverId = user.uid;
              } else {
                lastMessage = newData[FirebaseConfig.field_text];
                isReceiver = true;
                receiverId = user.uid;
              }

              Conversation conversation = Conversation(
                  name: user.name,
                  id: document.id,
                  lastMessage: lastMessage,
                  markAsRead: markAsRead,
                  isReceiver: isReceiver,
                  receiverId: receiverId);

              users.add(conversation);
              setState(() {});
            }
          });
        });
      }
    }
  }

  void fetchMyUsers(String searchText, int offset) {
    // UserService(context).getUsers(offset).then((value) {
    //   users.addAll(value);
    //   setState(() {});
    // }).onError((error, stackTrace) {
    //   CommonMethods.showToast(context, error.toString());
    // });
  }

  void followUnfollowUser(String id, String name) {
    UserService(context).sendFollowRequest(id, name);
  }

  void onItemTap(Conversation conversation, String currentUserID) {
    String cId = conversation.id;
    int from = 0;
    if (currentUserID == cId.split("#").last) {
      from = 1;
    }
    MessageService(context).setMarkAsRead(
        conversation.id, from, () => navigateToChat(conversation));
  }

  void navigateToChat(Conversation conversation) {
    setState(() {});
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatScreen(conversation: conversation);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.favorite,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const FollowRequestsScreen();
              }));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () {
              AuthService(context).logout();
            },
          )
        ], title: const Text(StringConfig.usersText)),
        body: Column(
          children: [
            SearchInput(
              fetchMyUsers: fetchMyUsers,
              searchText: searchText,
            ),
            Expanded(
              flex: 1,
              child: HomeList(
                  users: users,
                  isLoading: _isLoading,
                  onItemTap: onItemTap,
                  searchText: searchText,
                  fetchMyUsers: fetchMyUsers,
                  currentUserID: currentUserID),
            )
          ],
        ));
  }
}

class SearchInput extends StatefulWidget {
  SearchInput(
      {super.key, required this.fetchMyUsers, required this.searchText});

  final Function fetchMyUsers;
  String searchText;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          widget.searchText = value;
        },
        decoration: const InputDecoration(
            hintText: StringConfig.searchUserText,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search)),
      ),
    );
  }
}

class HomeList extends StatefulWidget {
  HomeList(
      {super.key,
      required this.users,
      required this.isLoading,
      required this.onItemTap,
      required this.searchText,
      required this.fetchMyUsers,
      required this.currentUserID});

  final Function onItemTap;
  final Function fetchMyUsers;
  final bool isLoading;
  final String searchText;
  final List<Conversation> users;
  String? currentUserID = "";

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  ScrollController scrollController = ScrollController();
  Stream? stream;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.deepPurple,
        strokeWidth: 2.0,
        onRefresh: () async {
          return;
        },
        child: ListView.builder(
          controller: scrollController,
          itemCount: widget.users.length,
          itemBuilder: (context, index) {
            return ChatListItem(
                conversation: widget.users[index],
                index: index,
                onItemTap: () => widget.onItemTap(
                    widget.users[index], widget.currentUserID));
          },
        ));
  }
}

class ChatListItem extends StatelessWidget {
  const ChatListItem(
      {super.key,
      required this.conversation,
      required this.index,
      required this.onItemTap});

  final Conversation conversation;
  final int index;
  final Function onItemTap;

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
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.name,
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Text(conversation.lastMessage,
                      maxLines: 1, style: const TextStyle(color: Colors.black)),
                ],
              ),
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                    color: (conversation.isReceiver && !conversation.markAsRead)
                        ? Colors.deepPurple
                        : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
