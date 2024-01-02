import 'package:firebase_demo/app/base_config/configs/string_config.dart';
import 'package:firebase_demo/app/data/models/user.dart';
import 'package:firebase_demo/app/services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
  }

  void fetchMyUsers(String searchText, int offset) {}

  void deleteMyUser(String id) {}

  void onItemTap(User user) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
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
                  searchText: searchText,
                  offset: _offset,
                  total: _total,
                  isLoading: _isLoading,
                  deleteMyUser: deleteMyUser,
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
    required this.isLoading,
    required this.total,
    required this.offset,
    required this.onItemTap,
    required this.deleteMyUser,
    required this.fetchMyUsers,
    required this.searchText,
  });

  final Function deleteMyUser;
  final Function onItemTap;
  final Function fetchMyUsers;
  final bool isLoading;
  final int total;
  final int offset;
  final String searchText;

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
    List<User> usersList = [];

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.amber,
      strokeWidth: 2.0,
      onRefresh: () async {
        return;
      },
      child: ListView.builder(
        controller: scrollController,
        itemCount: usersList.length,
        itemBuilder: (context, index) {
          return HomeListItem(
              user: usersList[index],
              index: index,
              onItemTap: () => widget.onItemTap(usersList[index]),
              onDeleteTap: () => widget.deleteMyUser(usersList[index].uid));
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
      required this.onDeleteTap,
      required this.onItemTap});

  final User user;
  final int index;
  final Function onDeleteTap;
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
            InkWell(
              onTap: () => {onDeleteTap()},
              child: const Icon(
                Icons.delete,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
