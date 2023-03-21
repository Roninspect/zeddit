// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loginBTN.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityPage extends ConsumerWidget {
  final String name;
  const CommunityPage({
    super.key,
    required this.name,
  });

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinOrLeaveCommunity(
      WidgetRef ref, CommunityModel communityModel, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joiningAndLeavingCommuninty(communityModel, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetails = ref.watch(userProvider)!;

    final isGuest = !userDetails.isAuthenticated;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      expandedHeight: 150,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Align(
                              alignment: Alignment.topLeft,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                                radius: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0)
                                  .copyWith(left: 0, top: 10, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "r/${community.name}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  !isGuest
                                      ? community.mods.contains(userDetails.uid)
                                          ? OutlinedButton(
                                              onPressed: () {
                                                navigateToModTools(context);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(12)
                                                        .copyWith(
                                                            left: 30,
                                                            right: 30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: const Text("Mod Tools"),
                                            )
                                          : OutlinedButton(
                                              onPressed: () =>
                                                  joinOrLeaveCommunity(
                                                      ref, community, context),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(12)
                                                        .copyWith(
                                                            left: 30,
                                                            right: 30),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Text(community.members
                                                      .contains(userDetails.uid)
                                                  ? "joined"
                                                  : "Join"),
                                            )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                            Text("${community.members.length} members")
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text("Posts", style: TextStyle(fontSize: 18)),
                      ),
                      ref.watch(getCommunityPostProvider(name)).when(
                            data: (posts) {
                              return Expanded(
                                child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: posts.length,
                                    itemBuilder: (context, index) {
                                      var post = posts[index];
                                      return PostCard(post: post);
                                    }),
                              );
                            },
                            error: (error, stackTrace) =>
                                ErrorText(error: error.toString()),
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                          )
                    ],
                  ),
                )),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const CircularProgressIndicator(),
          ),
    );
  }
}
