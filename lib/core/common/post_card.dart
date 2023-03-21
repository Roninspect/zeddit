// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/like_btn.dart';
import 'package:reddit_clone/core/constants/constants.dart';

import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/create_post/controller/post_controller.dart';
import 'package:reddit_clone/theme/palette.dart';

import '../../models/post_model.dart';

// ignore: must_be_immutable
class PostCard extends ConsumerWidget {
  Post post;

  PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(postControllerProvider.notifier).deletePost(post.postId, context);
  }

  void upvote(
      {required WidgetRef ref,
      required String userId,
      required String triggererId}) {
    ref
        .watch(postControllerProvider.notifier)
        .upvote(post, userId, triggererId);
  }

  void downvote(
      {required WidgetRef ref,
      required String userId,
      required String triggererId}) {
    ref
        .watch(postControllerProvider.notifier)
        .downvote(post, userId, triggererId);
  }

  void awardPost(
      {required WidgetRef ref,
      required String award,
      required BuildContext context}) {
    ref
        .watch(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  late BuildContext dialogContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final currentTheme = ref.watch(themeProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return InkWell(
      onTap: () => Routemaster.of(context)
          .push('/${post.communityName}/post/${post.postId}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Material(
              elevation: 2,
              child: Container(
                // height: 400,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: currentTheme.drawerTheme.backgroundColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(post.communityProfile),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => navigateToCommunity(context),
                                child: Text(
                                  'r/${post.communityName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => navigateToUser(context),
                                child: Text(
                                  'u/${post.userName}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user.awards.isNotEmpty) ...[
                          Expanded(
                            child: SizedBox(
                              height: 25,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder: (context, index) {
                                    final award = post.awards[index];
                                    return Image.asset(
                                      Constants.awards[award]!,
                                      height: 30,
                                    );
                                  }),
                            ),
                          )
                        ],
                        const Spacer(),
                        ref
                            .watch(
                                getCommunityByNameProvider(post.communityName))
                            .when(
                              data: (community) => user != null &&
                                      (post.uid == user.uid ||
                                          community.mods.contains(user.uid))
                                  ? IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Are You Sure?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      deletePost(ref, context);
                                                      Routemaster.of(
                                                              dialogContext)
                                                          .pop();
                                                    },
                                                    child: const Text("Yes")),
                                                TextButton(
                                                    onPressed: () {
                                                      Routemaster.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text("No"))
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete),
                                    )
                                  : const SizedBox(),
                              error: (error, stackTrace) =>
                                  ErrorText(error: error.toString()),
                              loading: () => const CircularProgressIndicator(),
                            )
                      ],
                    ),
                    Text(
                      post.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (isTypeImage)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            post.link!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    if (isTypeText)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: double.infinity,
                            child: Text(post.description!)),
                      ),
                    isGuest
                        ? const SizedBox()
                        : Row(
                            children: [
                              LikeBtn(
                                  post: post,
                                  onDownvote: () => downvote(
                                      ref: ref,
                                      userId: post.uid,
                                      triggererId: user.uid),
                                  onUpvote: () => upvote(
                                      ref: ref,
                                      triggererId: user.uid,
                                      userId: post.uid)),
                              RouteData.of(context).path ==
                                      '/${post.communityName}/post/${post.postId}'
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        '${post.commentCount} comments',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : IconButton(
                                      style: IconButton.styleFrom(
                                          side: const BorderSide(
                                        color: Colors.white,
                                        width: 0.5,
                                      )),
                                      onPressed: () => Routemaster.of(context).push(
                                          '/${post.communityName}/post/${post.postId}'),
                                      icon: Text(post.commentCount == 0
                                          ? "Commnent"
                                          : "${post.commentCount} comments")),
                              const Spacer(),
                              IconButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0)
                                              .copyWith(left: 20, top: 20),
                                          child: const Text('Awards',
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            itemCount: user.awards.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4),
                                            itemBuilder: (context, index) {
                                              final award = user.awards[index];
                                              return GestureDetector(
                                                onTap: () async {
                                                  awardPost(
                                                      ref: ref,
                                                      context: context,
                                                      award: award);
                                                  Routemaster.of(context).pop();
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    Constants.awards[award]!,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.card_giftcard_outlined),
                                color: Colors.grey,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
