// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/create_post/controller/post_controller.dart';
import '../../models/post_model.dart';

class LikeBtn extends ConsumerWidget {
  Post post;
  VoidCallback onUpvote;
  VoidCallback onDownvote;

  LikeBtn({
    Key? key,
    required this.post,
    required this.onUpvote,
    required this.onDownvote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('like build');
    final user = ref.watch(userProvider);

    return Row(
      children: [
        IconButton(
          onPressed: onUpvote,
          icon: Icon(
            Icons.thumb_up_alt_sharp,
            color: post.upvotes.contains(user?.uid) ? Colors.blue : Colors.grey,
          ),
        ),
        Text(
          '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: onDownvote,
          icon: const Icon(Icons.thumb_down),
          color: post.downvotes.contains(user?.uid)
              ? Colors.deepOrange
              : Colors.grey,
        ),
      ],
    );
  }
}
