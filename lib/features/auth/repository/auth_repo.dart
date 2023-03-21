import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/constants/firebase_enums.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/models/user_models.dart';

final authRepoProvider = Provider((ref) => AuthRepo(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleProvider)));

class AuthRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepo({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _user =>
      _firestore.collection(FirebaseName.users.name);

  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final credential = GoogleAuthProvider.credential(
        accessToken: (await googleUser!.authentication).accessToken,
        idToken: (await googleUser.authentication).idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      late UserModel userDetails;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userDetails = UserModel(
            name: userCredential.user!.displayName ?? "No Name",
            profilePic:
                userCredential.user!.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: <String>[
              'awesomeAns',
              'gold',
              'platinum',
              'helpful',
              'plusone',
              'rocket',
              'thankyou',
              'til'
            ]);
        await _user.doc(userCredential.user!.uid).set(userDetails.toMap());
      } else {
        userDetails = await getUserData(userCredential.user!.uid).first;
      }
      return right(userDetails);
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, UserModel>> guestSignIn() async {
    try {
      var userCredential = await _auth.signInAnonymously();
      UserModel userDetails = UserModel(
          name: 'guest',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: false,
          karma: 0,
          awards: <String>[]);
      await _user.doc(userCredential.user!.uid).set(userDetails.toMap());

      return right(userDetails);
    } catch (e) {
      return left(e.toString());
    }
  }

  Stream<User?> get getAuthChanges => _auth.authStateChanges();

  Stream<UserModel> getUserData(String uid) {
    return _user.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }
}
