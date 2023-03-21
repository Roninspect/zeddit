import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/theme/palette.dart';

import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0).copyWith(top: 20, bottom: 30),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 50,
            ),
          ),
          Text("u/${user.name}", style: const TextStyle(fontSize: 20)),
          const Divider(thickness: 2),
          ListTile(
            onTap: () {
              // Routemaster.of(context).pop();
              Routemaster.of(context).push('/u/${user.uid}');
            },
            leading: const Icon(Icons.person),
            title: const Text("My Profile"),
          ),
          ListTile(
            onTap: () async {
              await GoogleSignIn().signOut();

              await FirebaseAuth.instance.signOut();
              ref.watch(userProvider.notifier).update((state) => null);
            },
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text("LogOut"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.light_mode),
              Switch.adaptive(
                value: ref.watch(themeProvider.notifier).mode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                  // ignore: unused_result
                  ref.refresh(themeProvider);
                },
              ),
              const Icon(Icons.dark_mode),
            ],
          )
        ],
      )),
    );
  }
}
