// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';

import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/create_post/controller/post_controller.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('page build');
    return const FeedList();
  }
}

class FeedList extends ConsumerWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetails = ref.watch(userProvider)!;

    final isGuest = !userDetails.isAuthenticated;
    return isGuest
        ? ref.watch(guestPostProvider).when(
              data: (data) {
                return ListView.builder(
                  key: const PageStorageKey(0),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return PostCard(
                      post: data[index],
                    );
                  },
                );
              },
              error: (error, stackTrace) {
                return ErrorText(error: error.toString());
              },
              loading: () => const CircularProgressIndicator(),
            )
        : ref.watch(userCommunityProvider).when(
              data: (communities) {
                return ref.watch(userPostProvider(communities)).when(
                      data: (data) {
                        return ListView.builder(
                          key: const PageStorageKey(0),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: data[index],
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) {
                        return ErrorText(error: error.toString());
                      },
                      loading: () => const CircularProgressIndicator(),
                    );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const CircularProgressIndicator(),
            );
  }
}
