// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/profile/controller/profile_controller.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/common/error_text.dart';
import '../../auth/controller/auth_controller.dart';

class UserProfile extends ConsumerWidget {
  String uid;

  UserProfile({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final userDetails = ref.watch(userProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: ref.watch(getUserDataProvider(uid)).when(
              data: (user) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  String _name = user.name;
                  return [
                    SliverAppBar(
                      // floating: true,
                      // snap: true,
                      expandedHeight: 150,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              user.banner,
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
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0)
                                  .copyWith(left: 0, top: 10, bottom: 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _name.length > 20
                                          ? 'u/${_name.substring(0, 20)}...'
                                          : 'u/$_name',
                                      style: const TextStyle(fontSize: 20),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text("${user.karma} karma")
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: OutlinedButton(
                                onPressed: () => Routemaster.of(context)
                                    .push('/edit-profile/$uid/$_name'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.all(12)
                                      .copyWith(left: 30, right: 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Edit Profile",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ];
                },
                body: ref.watch(getUserPostProvider(user.uid)).when(
                      data: (posts) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child:
                                  Text("Posts", style: TextStyle(fontSize: 20)),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    var post = posts[index];
                                    return PostCard(post: post);
                                  }),
                            ),
                          ],
                        ),
                      ),
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const CircularProgressIndicator(),
                    ),
              ),
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const CircularProgressIndicator(),
            ),
      ),
    );
  }
}
