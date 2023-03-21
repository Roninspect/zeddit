import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/utils.dart';
import 'package:reddit_clone/core/constants/karma_enums.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/create_post/repository/post_repository.dart';
import 'package:reddit_clone/features/profile/controller/profile_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/storage_provider.dart';
import '../../../models/comment_model.dart';
import '../../../models/notification_model.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>(
    (ref) => PostController(
        postRepository: ref.watch(postRepository),
        ref: ref,
        storageRepository: ref.watch(storageRepositoryProvider)));

final userPostProvider =
    StreamProvider.family<List<Post>, List<CommunityModel>>(
  (ref, communities) {
    final postController = ref.watch(postControllerProvider.notifier);
    return postController.fetchPost(communities);
  },
);

final guestPostProvider = StreamProvider(
    (ref) => ref.watch(postControllerProvider.notifier).guestPost());

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  return ref.watch(postControllerProvider.notifier).getPostById(postId);
});

final getCommentProvider = StreamProvider.autoDispose.family(
    (ref, String postId) =>
        ref.watch(postControllerProvider.notifier).getComments(postId));

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required String description,
    required CommunityModel selectedCommunity,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.watch(userProvider)!;

    final post = Post(
        postId: postId,
        title: title,
        description: description,
        communityName: selectedCommunity.name,
        communityProfile: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        userName: user.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: []);

    final res = await _postRepository.addPost(post, user.uid);
    _ref.read(profileControllerProvider.notifier).updateKarma(Karma.textPost);
    state = false;

    res.fold((l) => showsnackBar(context, l.toString()), (r) {
      showsnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost(
      {required BuildContext context,
      required String title,
      required CommunityModel selectedCommunity,
      required File file}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.watch(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imageRes.fold(
      (l) => showsnackBar(context, l.toString()),
      (r) async {
        final post = Post(
            postId: postId,
            title: title,
            link: r,
            communityName: selectedCommunity.name,
            communityProfile: selectedCommunity.avatar,
            upvotes: [],
            downvotes: [],
            commentCount: 0,
            userName: user.name,
            uid: user.uid,
            type: 'image',
            createdAt: DateTime.now(),
            awards: []);

        final res = await _postRepository.addPost(post, user.uid);
        _ref
            .read(profileControllerProvider.notifier)
            .updateKarma(Karma.imagePost);
        state = false;

        res.fold((l) => showsnackBar(context, l.toString()), (r) {
          showsnackBar(context, 'Posted Successfully');
          Routemaster.of(context).replace('/r/${selectedCommunity.name}');
        });
      },
    );
  }

  void deletePost(String postId, BuildContext context) async {
    final res = await _postRepository.deletePost(postId);
    res.fold((l) => showsnackBar(context, l.toString()),
        (r) => showsnackBar(context, "Post deleted"));
  }

  void upvote(Post post, String userId, String triggererId) {
    final user = _ref.watch(userProvider);
    NotificationModel notificationModel = NotificationModel(
        communityName: post.communityName,
        triggererName: user!.name,
        posterName: post.userName,
        triggerer: user.uid,
        type: 'like',
        postId: post.postId,
        poster: post.uid);
    _postRepository.upvote(
        trigerrerId: triggererId,
        posterId: post.postId,
        userId: post.uid,
        post: post,
        notification: notificationModel);
  }

  void downvote(Post post, String userId, String triggererId) {
    _postRepository.downvote(post, userId, triggererId);
  }

  Future<void> refreshPost(List<CommunityModel> communities) async {
    final completer = Completer<void>();
    final stream = fetchPost(communities);

    // Initialize subscription before listen method call
    late final StreamSubscription<List<Post>> subscription;

    subscription = stream.listen((data) {
      subscription.cancel();
      completer.complete();
    }, onError: (error) {
      subscription.cancel();
      completer.completeError(error);
    });

    return completer.future;
  }

  Stream<List<Post>> fetchPost(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  //* get post by id to enter in full mode
  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  //* post comment on a post
  void addComments(
      {required BuildContext context,
      required String text,
      required String postId,
      required String communityName,
      required String poster,
      required String posterName,
      required String posterid}) async {
    final user = _ref.watch(userProvider);
    String id = const Uuid().v1();
    CommentModel comment = CommentModel(
        id: id,
        text: text,
        createdAt: DateTime.now(),
        postId: postId,
        userId: user!.uid,
        profilePic: user.profilePic,
        username: user.name,
        communityName: communityName);
    NotificationModel notification = NotificationModel(
      triggerer: user.uid,
      triggererName: user.name,
      type: 'commented',
      postId: postId,
      poster: poster,
      posterName: posterName,
      communityName: communityName,
    );
    final res = await _postRepository.addComments(comment);

    res.fold((l) => showsnackBar(context, l.toString()), (r) async {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(comment.postId)
          .update({'commentCount': FieldValue.increment(1)});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(posterid)
          .collection('notifications')
          .doc()
          .set(notification.copyWith(type: 'commented').toMap());
    });
  }

  //* award post

  void awardPost(
      {required Post post,
      required String award,
      required BuildContext context}) async {
    final user = _ref.watch(userProvider);
    final res = await _postRepository.giveAwards(post, award, user!.uid);

    res.fold((l) => showsnackBar(context, l.toString()), (r) {
      _ref
          .read(profileControllerProvider.notifier)
          .updateKarma(Karma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
    });
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _postRepository.getComments(postId);
  }

  Stream guestPost() {
    return _postRepository.fetchGuestPosts();
  }
}
