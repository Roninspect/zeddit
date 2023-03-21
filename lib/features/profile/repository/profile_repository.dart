import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/models/user_models.dart';

import '../../../core/constants/firebase_enums.dart';
import '../../../core/failure.dart';
import '../../../core/type_defs.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(firestore: ref.watch(firestoreProvider));
});

class ProfileRepository {
  final FirebaseFirestore _firestore;
  ProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  //* editing profile of community
  FutureVoid editProfile(UserModel userModel) async {
    try {
      return right(await _user.doc(userModel.uid).update(userModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //* update karma
  FutureVoid updateKarma(UserModel userModel) async {
    try {
      return right(
        await _user.doc(userModel.uid).update({'karma': userModel.karma}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => Post.fromMap(e.data())).toList());
  }

  CollectionReference get _user =>
      _firestore.collection(FirebaseName.users.name);
}
