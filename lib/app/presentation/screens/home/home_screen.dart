import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/data/models/user.dart';
import 'package:firebase_demo/app/presentation/screens/chat/chat_screen.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
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
  final int _total = 0;
  final int _offset = 0;
  String searchText = "";
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchMyUsers("", 0);
  }

  void fetchMyUsers(String searchText, int offset) {
    UserService(context).getUsers(offset).then((value) {
      users.addAll(value);
      setState(() {});
    }).onError((error, stackTrace) {
      CommonMethods.showToast(context, error.toString());
    });
  }

  void followUnfollowUser(String id) {}

  void onItemTap(User user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatScreen(user: user);
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
            onPressed: () {},
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
                  searchText: searchText,
                  offset: _offset,
                  total: _total,
                  isLoading: _isLoading,
                  followUnfollowUser: followUnfollowUser,
                  onItemTap: onItemTap,
                  fetchMyUsers: fetchMyUsers),
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
  const HomeList({
    super.key,
    required this.users,
    required this.isLoading,
    required this.total,
    required this.offset,
    required this.onItemTap,
    required this.followUnfollowUser,
    required this.fetchMyUsers,
    required this.searchText,
  });

  final Function followUnfollowUser;
  final Function onItemTap;
  final Function fetchMyUsers;
  final bool isLoading;
  final int total;
  final int offset;
  final String searchText;
  final List<User> users;

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ((scrollController.position.maxScrollExtent ==
              scrollController.offset) &&
          !widget.isLoading) {
        if (widget.total >= widget.offset + 10) {}
      }
    });
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
      child: ListView.builder(
        controller: scrollController,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return HomeListItem(
              user: widget.users[index],
              index: index,
              onItemTap: () => widget.onItemTap(widget.users[index]),
              onFollowUnfollowTap: () =>
                  widget.followUnfollowUser(widget.users[index].uid));
        },
      ),
    );
  }
}

class HomeListItem extends StatelessWidget {
  const HomeListItem(
      {super.key,
      required this.user,
      required this.index,
      required this.onFollowUnfollowTap,
      required this.onItemTap});

  final User user;
  final int index;
  final Function onFollowUnfollowTap;
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
                        style: const TextStyle(color: Colors.black)),
                  ],
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.deepPurple,
              ),
              child: InkWell(
                onTap: () => {onFollowUnfollowTap()},
                child: const Text(
                  StringConfig.followText,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
