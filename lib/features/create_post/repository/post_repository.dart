import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/community_model.dart';

import '../../../core/constants/karma_enums.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/comment_model.dart';
import '../../../models/post_model.dart';
import '../../../models/notification_model.dart';
import '../../profile/controller/profile_controller.dart';

final postRepository = Provider<PostRepository>((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider), ref: ref);
});

class PostRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;
  PostRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

  CollectionReference get _posts => _firestore.collection('posts');
  CollectionReference get _comments => _firestore.collection('comments');

  FutureVoid addPost(Post post, String userId) async {
    try {
      return right(await _posts.doc(post.postId).set(post.toMap()));
    } on FirebaseException {
      rethrow;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //
  Stream<List<Post>> fetchUserPosts(List<CommunityModel> communities) {
    List<List<String>> batches =
        _chunkList(communities.map((e) => e.name).toList(), 10);
    Stream<List<Post>>? stream;

    for (var batch in batches) {
      var query = _posts
          .where('communityName', whereIn: batch)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList());

      if (stream == null) {
        stream = query;
      } else {
        stream = stream
            .asyncExpand((data) => query.map((event) => [...data, ...event]));
      }
    }

    return stream ?? const Stream.empty();
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    int numChunks = (list.length / chunkSize).ceil();
    for (var i = 0; i < numChunks; i++) {
      int start = i * chunkSize;
      int end = (i + 1) * chunkSize;
      chunks.add(list.sublist(start, end < list.length ? end : list.length));
    }
    return chunks;
  }

  //* fetching guest post

  Stream<List<Post>> fetchGuestPosts() {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  //* delete post

  FutureVoid deletePost(String postId) async {
    try {
      final res = await _posts.doc(postId).delete();
      _ref
          .read(profileControllerProvider.notifier)
          .updateKarma(Karma.deletePost);
      return right(res);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //* upvoting and downvoting a post

  void upvote(
      {required Post post,
      required String userId,
      required trigerrerId,
      required NotificationModel notification,
      required String posterId}) async {
    if (post.downvotes.contains(trigerrerId)) {
      await _posts.doc(post.postId).update({
        'downvotes': FieldValue.arrayRemove([trigerrerId])
      });
      await _posts.doc(post.postId).update({
        'upvotes': FieldValue.arrayUnion([trigerrerId])
      });
      trigerrerId != post.uid
          ? await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc()
              .set(notification.copyWith(type: 'liked').toMap())
          : null;
      // : null;
    } else if (post.upvotes.contains(trigerrerId)) {
      await _posts.doc(post.postId).update({
        'upvotes': FieldValue.arrayRemove([trigerrerId])
      });
      if (trigerrerId != post.uid) {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('postId', isEqualTo: post.postId)
            .where('type', isEqualTo: 'liked')
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } else {
      await _posts.doc(post.postId).update({
        'upvotes': FieldValue.arrayUnion([trigerrerId])
      });
      // userId != post.uid
      trigerrerId != post.uid
          ? await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc()
              .set(notification.copyWith(type: 'liked').toMap())
          : null;
    }
  }

  void downvote(Post post, String userId, String trigerrerId) async {
    if (post.downvotes.contains(trigerrerId)) {
      await _posts.doc(post.postId).update({
        'downvotes': FieldValue.arrayRemove([trigerrerId])
      });
    } else if (post.upvotes.contains(trigerrerId)) {
      await _posts.doc(post.postId).update({
        'upvotes': FieldValue.arrayRemove([trigerrerId])
      });
      await _posts.doc(post.postId).update({
        'downvotes': FieldValue.arrayUnion([trigerrerId])
      });
      if (trigerrerId != post.uid) {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('postId', isEqualTo: post.postId)
            .where('type', isEqualTo: 'liked')
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } else {
      await _posts.doc(post.postId).update({
        'downvotes': FieldValue.arrayUnion([trigerrerId])
      });
      if (trigerrerId != post.uid) {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('postId', isEqualTo: post.postId)
            .where('type', isEqualTo: 'liked')
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

//* posting comments
  FutureVoid addComments(CommentModel comment) async {
    try {
      final res = await _comments.doc(comment.id).set(comment.toMap());
      _ref.read(profileControllerProvider.notifier).updateKarma(Karma.comment);
      return right(res);
    } on FirebaseException {
      rethrow;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // //* getting comments
  Stream<List<CommentModel>> getComments(String postId) {
    return _comments
        .where("postId", isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => CommentModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  //* awards

  FutureVoid giveAwards(Post post, String award, String senderId) async {
    try {
      final res = await _posts.doc(post.postId).update({
        'awards': FieldValue.arrayUnion([award])
      });
      await _firestore.collection('users').doc(senderId).update({
        'awards': FieldValue.arrayRemove([award])
      });
      return right(await _firestore.collection('users').doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award])
      }));
    } on FirebaseException {
      rethrow;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
