import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:rflutter/core/constants/constants.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/features/home/delegate/community_search_delegate.dart';
import 'package:rflutter/features/home/drawer/community_drawer.dart';
import 'package:rflutter/features/home/drawer/profile_drawer.dart';
import 'package:rflutter/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayProfileDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currentTheme = ref.watch(themeNotifyProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                displayDrawer(context);
              },
              icon: Icon(Icons.menu),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchCommunityDelegate(ref: ref));
            },
            icon: Icon(Icons.search),
          ),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  displayProfileDrawer(context);
                },
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user!.profilePic),
                ),
              );
            },
          ),
        ],
      ),
      drawer: CommunityDrawer(),
      endDrawer: ProfileDrawer(),
      body: Constants.items[_page],
      bottomNavigationBar: CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: '')
        ],
        onTap: (value) {
          onChanged(value);
        },
        currentIndex: _page,
      ),
    );
  }
}
