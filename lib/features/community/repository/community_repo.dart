import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_enums.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/user_models.dart';

import '../../../core/type_defs.dart';
import '../../../models/post_model.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(CommunityModel communityModel) async {
    try {
      var communityDoc = await _comunities.doc(communityModel.name).get();
      if (communityDoc.exists) {
        throw "Community name Taken";
      } else {
        return right(
          await _comunities.doc(communityModel.name).set(
                communityModel.toMap(),
              ),
        );
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //* Joining a community

  FutureVoid addMember(String communityName, String userId) async {
    try {
      return right(await _comunities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //* leaving a community
  FutureVoid leaveMember(String communityName, String userId) async {
    try {
      return right(await _comunities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> getuserCommunity(String uid) {
    return _comunities
        .where(FirebaseName.members.name, arrayContains: uid)
        .snapshots()
        .map(
      (event) {
        List<CommunityModel> communities = [];
        for (var doc in event.docs) {
          communities
              .add(CommunityModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        return communities;
      },
    );
  }

  Stream<CommunityModel> getCommunityByName(String name) {
    return _comunities.doc(name).snapshots().map((event) =>
        CommunityModel.fromMap(event.data() as Map<String, dynamic>));
  }

  //* editing profile of community
  FutureVoid editCommunity(CommunityModel communityModel) async {
    try {
      return right(await _comunities
          .doc(communityModel.name)
          .update(communityModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _comunities
        .where('name',
            isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
            isLessThan: query.toLowerCase().isEmpty
                ? null
                : query.substring(0, query.length - 1) +
                    String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
        .snapshots()
        .map(
      (event) {
        List<CommunityModel> communitiesResult = [];
        for (var community in event.docs) {
          communitiesResult.add(
              CommunityModel.fromMap(community.data() as Map<String, dynamic>));
        }
        return communitiesResult;
      },
    );
  }

  FutureVoid saveMods(List mods, String communityName) async {
    try {
      return right(await _comunities.doc(communityName).update({'mods': mods}));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPost(String name) {
    return _firestore
        .collection('posts')
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => Post.fromMap(e.data())).toList());
  }

  CollectionReference get _comunities =>
      _firestore.collection(FirebaseName.communities.name);
}
