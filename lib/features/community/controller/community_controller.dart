import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/providers/storage_provider.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/repository/community_repo.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/utils.dart';
import '../../../core/failure.dart';
import '../../../models/post_model.dart';

//* comminty controller provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) =>
        CommunityController(
            communityRepository: ref.watch(communityRepositoryProvider),
            storageRepository: ref.watch(storageRepositoryProvider),
            ref: ref));

//* userComminty stream Provider
final userCommunityProvider = StreamProvider.autoDispose((ref) {
  debugPrint("provider created");
  return ref.watch(communityControllerProvider.notifier).getuserCommunity();
});

//* getting user communiy bu name controller
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

//* searching for a community
final searchCommunityProvider = StreamProvider.family((ref, String query) =>
    ref.watch(communityControllerProvider.notifier).searchCommunity(query));

//* getting post for a community
final getCommunityPostProvider =
    StreamProvider.autoDispose.family((ref, String communityName) {
  debugPrint("post provider created at $communityName");
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityPost(communityName);
});

//* main comminty controller class
class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);
//* creating a community
  void createCommunity(
      {required String name, required BuildContext context}) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    CommunityModel communityModel = CommunityModel(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [uid],
        mods: [uid]);

    final res = await _communityRepository.createCommunity(communityModel);
    if (mounted) {}
    state = false;

    res.fold((l) => showsnackBar(context, l.message), (r) async {
      Routemaster.of(context).push('/r/$name');
    });
  }

  //* joining and leaving a community
  void joiningAndLeavingCommuninty(
      CommunityModel communityModel, BuildContext context) async {
    Either<Failure, void> res;
    final user = _ref.watch(userProvider);
    if (communityModel.members.contains(user!.uid)) {
      res =
          await _communityRepository.leaveMember(communityModel.name, user.uid);
    } else {
      res = await _communityRepository.addMember(communityModel.name, user.uid);
    }
    res.fold((l) => showsnackBar(context, l.toString()), (r) {
      if (communityModel.members.contains(user.uid)) {
        showsnackBar(context, "left community successfully");
        Routemaster.of(context).pop();
      }
      showsnackBar(context, "Joined community successfully");
    });
  }

  //* getting the communty list from community repository to show in the ui

  Stream<List<CommunityModel>> getuserCommunity() {
    final uid = _ref.read(userProvider)!.uid;

    return _communityRepository.getuserCommunity(uid);
  }

  Stream<CommunityModel> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  //* editing community details
  void editCommunity(
      {required CommunityModel communityModel,
      required File? profile,
      required File? banner,
      required BuildContext context,
      required String name}) async {
    if (profile != null) {
      state = true;
      final res = await _storageRepository.storeFile(
        path: "communities/profile",
        id: communityModel.name,
        file: profile,
      );
      state = false;
      res.fold((l) => showsnackBar(context, l.toString()),
          (r) => communityModel = communityModel.copyWith(avatar: r));
    }
    if (banner != null) {
      state = true;
      final res = await _storageRepository.storeFile(
        path: "communities/banner",
        id: communityModel.name,
        file: banner,
      );
      state = false;
      res.fold((l) => showsnackBar(context, l.toString()), (r) async {
        communityModel = communityModel.copyWith(banner: r);
      });
    }
    final res = await _communityRepository.editCommunity(communityModel);

    res.fold(
      (l) => showsnackBar(context, l.toString()),
      (r) async {
        Routemaster.of(context).replace('/r/$name');
      },
    );
  }

  //* save new mods
  void saveMods(List mods, String communityName, BuildContext context) async {
    final res = await _communityRepository.saveMods(mods, communityName);
    res.fold(
      (l) => ErrorText(error: l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  //* searching community
  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  Stream<List<Post>> getCommunityPost(String communityName) {
    return _communityRepository.getCommunityPost(communityName);
  }
}
