import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_demo/app/base_config/configs/firebase_config.dart';
import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/data/models/follow_request.dart';
import 'package:firebase_demo/app/data/models/user.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void followUnfollowUser(String id, String name) {
    UserService(context).sendFollowRequest(id, name);
  }

  void onItemTap(User user) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(StringConfig.followRequestsText)),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: HomeList(
                  users: users,
                  isLoading: _isLoading,
                  followUnfollowUser: followUnfollowUser,
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
      required this.isLoading,
      required this.onItemTap,
      required this.followUnfollowUser,
      required this.currentUserID});

  final Function followUnfollowUser;
  final Function onItemTap;
  final bool isLoading;
  final List<User> users;
  String? currentUserID = "";

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  ScrollController scrollController = ScrollController();
  Stream? stream;

  @override
  void initState() {
    super.initState();

    initMessages();
  }

  void initMessages() async {
    String? currentID = await AuthService(context).getCurrentUID();

    setState(() {
      widget.currentUserID = currentID;
    });

    if (currentID != null) {
      stream = FirebaseFirestore.instance
          .collection(FirebaseConfig.db_users)
          .doc(currentID)
          .collection(FirebaseConfig.db_followRequests)
          .snapshots();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

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
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            var users = snapshot.data!.docs;

            return ListView.builder(
              controller: scrollController,
              itemCount: users.length,
              itemBuilder: (context, index) {
                FollowRequest newUser =
                    FollowRequest.fromJson(users[index].data());

                return HomeListItem(
                    followRequest: newUser,
                    index: index,
                    isApproved: newUser.isApproved,
                    onItemTap: () => widget.onItemTap(newUser),
                    onFollowUnfollowTap: () => widget.followUnfollowUser());
              },
            );
          }),
    );
  }
}

class HomeListItem extends StatelessWidget {
  const HomeListItem(
      {super.key,
      required this.followRequest,
      required this.index,
      required this.onFollowUnfollowTap,
      required this.isApproved,
      required this.onItemTap});

  final FollowRequest followRequest;
  final int index;
  final Function onFollowUnfollowTap;
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
                    Text(followRequest.name,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
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
