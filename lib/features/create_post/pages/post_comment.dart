// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/post_card.dart';
import 'package:reddit_clone/features/create_post/controller/post_controller.dart';

import '../../../models/post_model.dart';

class FullPost extends ConsumerStatefulWidget {
  final String postId;
  final String communityName;
  const FullPost({
    Key? key,
    required this.postId,
    required this.communityName,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FullPostState();
}

class _FullPostState extends ConsumerState<FullPost> {
  TextEditingController commentController = TextEditingController();

  //* add comment function
  void addComment(Post post) {
    ref.watch(postControllerProvider.notifier).addComments(
        posterid: post.uid,
        context: context,
        text: commentController.text,
        communityName: post.communityName,
        postId: post.postId,
        poster: post.userName,
        posterName: post.userName);
  }

  void navigateToUser(BuildContext context, String userId) {
    Routemaster.of(context).push('/u/$userId');
  }

  var format = DateFormat('dd-MMM-yy');

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("r/${widget.communityName}"),
        ),
        body: ref.watch(getPostByIdProvider(widget.postId)).when(
              data: (post) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PostCard(post: post),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Flexible(
                                    child: TextField(
                                      controller: commentController,
                                      decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey)),
                                        hintText: "What's your thought?",
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      addComment(post);
                                      commentController.clear();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: const Text("Post"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "All Comments",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ref.watch(getCommentProvider(post.postId)).when(
                                    data: (comments) {
                                      return comments.isNotEmpty
                                          ? ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: comments.length,
                                              itemBuilder: (context, index) {
                                                var comment = comments[index];
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            comment.profilePic),
                                                  ),
                                                  title: GestureDetector(
                                                    onTap: () => navigateToUser(
                                                        context,
                                                        comment.userId),
                                                    child: Text(
                                                      'u/${comment.username}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    comment.text,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                  trailing: Text(format.format(
                                                      comment.createdAt)),
                                                );
                                              },
                                            )
                                          : const Center(
                                              child: Text(
                                                  "be the first one to comment"),
                                            );
                                    },
                                    error: (error, stackTrace) =>
                                        ErrorText(error: error.toString()),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const CircularProgressIndicator(),
            ),
      ),
    );
  }
}
