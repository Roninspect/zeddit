import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/features/auth/repository/auth_repo.dart';
import 'package:reddit_clone/models/user_models.dart';
import '../../../core/common/utils.dart';

//* initializing the userprovider to get user information as UserModel
final userProvider = StateProvider<UserModel?>((ref) {
  return null;
});

//* accessing AuthController class to make it available globally
final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, bool>((ref) =>
        AuthController(authRepo: ref.watch(authRepoProvider), ref: ref));

//* to see the Authchanges as a Stream (to decide whether to show login or home in main())
final authStateChangeProvider = StreamProvider.autoDispose(
    (ref) => ref.watch(authControllerProvider.notifier).authStateChange);

// //*
final getUserDataProvider = StreamProvider.autoDispose.family(
    (ref, String uid) =>
        ref.watch(authControllerProvider.notifier).getuserData(uid));

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  final AuthRepo _authRepo;

  AuthController({required AuthRepo authRepo, required Ref ref})
      : _authRepo = authRepo,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepo.getAuthChanges;

  Stream<UserModel> getuserData(String uid) {
    return _authRepo.getUserData(uid);
  }

  void singInWithGoogle(BuildContext context) async {
    state = true;

    final user = await _authRepo.signInWithGoogle();

    state = false;
    user.fold(
      (l) => showsnackBar(
        context,
        l.toString(),
      ),
      (r) => _ref.read(userProvider.notifier).update((state) => r),
    );
  }

  void guestSignIn(BuildContext context) async {
    state = true;

    final user = await _authRepo.guestSignIn();

    state = false;
    user.fold(
      (l) => showsnackBar(
        context,
        l.toString(),
      ),
      (r) => _ref.read(userProvider.notifier).update((state) => r),
    );
  }
}
