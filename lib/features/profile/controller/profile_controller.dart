import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/constants/karma_enums.dart';
import 'package:reddit_clone/core/providers/storage_provider.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/profile/repository/profile_repository.dart';
import 'package:reddit_clone/models/user_models.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/utils.dart';
import '../../../models/post_model.dart';

final profileControllerProvider =
    StateNotifierProvider<ProfileController, bool>((ref) {
  return ProfileController(
      ref: ref,
      storageRepository: ref.watch(storageRepositoryProvider),
      profileRepository: ref.watch(profileRepositoryProvider));
});

final getUserPostProvider = StreamProvider.family((ref, String uid) =>
    ref.watch(profileControllerProvider.notifier).getUserPost(uid));

class ProfileController extends StateNotifier<bool> {
  final ProfileRepository _profileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;
  ProfileController(
      {required ProfileRepository profileRepository,
      required StorageRepository storageRepository,
      required Ref ref})
      : _profileRepository = profileRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);

  void editProfile(
      {required File? profile,
      required File? banner,
      required String profilename,
      required BuildContext context}) async {
    state = false;
    UserModel user = _ref.watch(userProvider)!;
    if (profile != null) {
      state = true;
      final res = await _storageRepository.storeFile(
        path: "users/profile",
        id: user.name,
        file: profile,
      );
      state = false;
      res.fold((l) => showsnackBar(context, l.toString()),
          (r) => user = user.copyWith(profilePic: r));
    }
    if (banner != null) {
      state = true;
      final res = await _storageRepository.storeFile(
        path: "communities/banner",
        id: user.name,
        file: banner,
      );
      state = false;
      res.fold((l) => showsnackBar(context, l.toString()),
          (r) => user = user.copyWith(banner: r));
    }

    user = user.copyWith(name: profilename);
    final res = await _profileRepository.editProfile(user);
    state = true;

    res.fold(
      (l) => showsnackBar(context, l.toString()),
      (r) async {
        _ref.read(userProvider.notifier).update((state) => user);
        showsnackBar(context, 'Profile Updated Successfully');
        Routemaster.of(context).replace('/u/${user.uid}');
      },
    );
  }

  //* update karma

  void updateKarma(Karma karma) async {
    final user = _ref.watch(userProvider);
    final updatedKarma = user!.copyWith(karma: user.karma + karma.karma);
    final res = await _profileRepository.updateKarma(updatedKarma);
    res.fold(
        (l) => null,
        (r) =>
            _ref.read(userProvider.notifier).update((state) => updatedKarma));
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _profileRepository.getUserPost(uid);
  }
}
