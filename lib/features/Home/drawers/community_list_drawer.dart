import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loginBTN.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/routes/router.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({Key? key}) : super(key: key);

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/${AppRoutes.createCommunity.name}');
  }

  void navigateToCommunity(BuildContext context, String name) {
    Routemaster.of(context).push('/r/$name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Drawer(
      width: 250,
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isGuest
                ? Column(
                    children: const [
                      Text(
                        'Create Community',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      SignInBTN(),
                    ],
                  )
                : ListTile(
                    onTap: () => navigateToCreateCommunity(context),
                    trailing: const Icon(
                      Icons.add,
                      color: Colors.blue,
                    ),
                    title: const Text(
                      "Create a Community",
                      style: TextStyle(fontSize: 15.4),
                    ),
                  ),
            const SizedBox(height: 10),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Your Communities",
                style: TextStyle(fontSize: 16),
              ),
            ),
            if (!isGuest)
              ref.watch(userCommunityProvider).when(
                    data: (communities) => Expanded(
                      child: ListView.separated(
                        itemCount: communities.length,
                        itemBuilder: (context, index) {
                          final community = communities[index];
                          return ListTile(
                            onTap: () =>
                                navigateToCommunity(context, community.name),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text(community.name),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const Divider(thickness: 0.86),
                      ),
                    ),
                    error: (error, stackTrace) {
                      return ErrorText(error: error.toString());
                    },
                    loading: () => const CircularProgressIndicator(),
                  )
          ],
        ),
      )),
    );
  }
}
