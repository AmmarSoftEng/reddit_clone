import 'package:flutter/material.dart';
import 'package:rflutter/features/auth/screen/login_screen.dart';
import 'package:rflutter/features/community/create_community_screen.dart';
import 'package:rflutter/features/community/screen/add_mod_screen.dart';
import 'package:rflutter/features/community/screen/mod_tool_screen.dart';
import 'package:rflutter/features/home/screen/home_screen.dart';
import 'package:rflutter/features/post/screen/add_post_type_screen.dart';
import 'package:rflutter/features/post/screen/comment_screen.dart';
import 'package:rflutter/features/userProfile/screen/edit_userprofile_screen.dart';
import 'package:rflutter/features/userProfile/screen/user_profile.dart';
import 'package:routemaster/routemaster.dart';

import 'features/community/screen/community_screen.dart';
import 'features/community/screen/edit_community_screen.dart';

final logOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child: LogInScreen()),
});

final logInRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(
        child: HomeScreen(),
      ),
  '/create-community': (_) => MaterialPage(child: CreateCommunityScreen()),
  '/community/:name': (route) => MaterialPage(
        child: CommunityScreen(name: route.pathParameters['name']!),
      ),
  '/mod-screen/:name': (route) => MaterialPage(
        child: ModTool(name: route.pathParameters['name']!),
      ),
  '/edit-community-screen/:name': (route) => MaterialPage(
        child: EditCommunityScreen(name: route.pathParameters['name']!),
      ),
  '/add-mod-screen/:name': (route) => MaterialPage(
        child: AddModsScreen(name: route.pathParameters['name']!),
      ),
  '/profile-screen/:id': (route) => MaterialPage(
        child: UserProfile(uid: route.pathParameters['id']!),
      ),
  '/edit-screen/:id': (route) => MaterialPage(
        child: EditProfileScreen(uid: route.pathParameters['id']!),
      ),
  '/post-type/:type': (route) => MaterialPage(
        child: PostType(type: route.pathParameters['type']!),
      ),
  '/add_comment/:id': (route) => MaterialPage(
        child: Comment(postId: route.pathParameters['id']!),
      ),
});
