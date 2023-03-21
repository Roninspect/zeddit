import 'package:flutter/material.dart';
import 'package:reddit_clone/features/auth/pages/login_page.dart';
import 'package:reddit_clone/features/community/pages/add_mod_page.dart';
import 'package:reddit_clone/features/community/pages/community_page.dart';
import 'package:reddit_clone/features/community/pages/create_community.dart';
import 'package:reddit_clone/features/community/pages/edit_community.dart';
import 'package:reddit_clone/features/community/pages/mod_tools_page.dart';
import 'package:reddit_clone/features/create_post/pages/add_post_type_page.dart';
import 'package:reddit_clone/features/create_post/pages/create_post_page.dart';
import 'package:reddit_clone/features/create_post/pages/post_comment.dart';
import 'package:reddit_clone/features/profile/pages/edit_profile.dart';
import 'package:reddit_clone/features/profile/pages/profile_page.dart';
import 'package:routemaster/routemaster.dart';
import '../features/Home/pages/home_page.dart';

enum AppRoutes { createCommunity }

final loogedOutRoutes = RouteMap(
  routes: {
    '/': (route) => const MaterialPage(child: LoginPage()),
  },
);

final loggedInRoutes = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomePage()),
  '/${AppRoutes.createCommunity.name}': (route) =>
      const MaterialPage(child: CreateCummunityPage()),
  '/r/:name': (route) =>
      MaterialPage(child: CommunityPage(name: route.pathParameters['name']!)),
  '/mod-tools/:name': (route) =>
      MaterialPage(child: ModToolsPage(name: route.pathParameters['name']!)),
  '/edit_Community/:name': (route) =>
      MaterialPage(child: EditCommunity(name: route.pathParameters['name']!)),
  '/add-mod/:name': (route) =>
      MaterialPage(child: AddModPage(name: route.pathParameters['name']!)),
  '/u/:uid': (route) =>
      MaterialPage(child: UserProfile(uid: route.pathParameters['uid']!)),
  '/edit-profile/:uid/:name': (route) => MaterialPage(
          child: EditProfile(
        uid: route.pathParameters['uid']!,
        name: route.pathParameters['name']!,
      )),
  '/create-post': (route) => const MaterialPage(child: CreatePostPage()),
  '/add-post/:type': (route) =>
      MaterialPage(child: AddPostType(type: route.pathParameters['type']!)),
  '/:communityName/post/:postId': (route) {
    return MaterialPage(
      child: FullPost(
          communityName: route.pathParameters['communityName']!,
          postId: route.pathParameters['postId']!),
    );
  }
});
