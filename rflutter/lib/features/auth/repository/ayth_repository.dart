import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rflutter/core/constants/constants.dart';
import 'package:rflutter/core/constants/firebase_constants.dart';
import 'package:rflutter/core/faliure.dart';
import 'package:rflutter/core/typedef.dart';
import 'package:rflutter/model/user_model.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
      firebaseAuth: ref.read(authProvider),
      firestore: ref.read(firestoreProvider),
      googleSignIn: ref.read(googleSigInProvider));
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseAuth firebaseAuth,
      required FirebaseFirestore firestore,
      required GoogleSignIn googleSignIn})
      : _auth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FuterEither<UserModel> signInWithGoogle() async {
    try {
      // to begin intereactive signIn process.
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();

// to Authenticate with google.
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

// cteate credintial
      final credential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken, accessToken: gAuth.accessToken);

// finally let sigIn
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      UserModel userModle;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModle = UserModel(
            name: userCredential.user!.displayName ?? "No name",
            profilePic:
                userCredential.user!.photoURL ?? Constants.bannerDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: []);
        await _users.doc(userCredential.user!.uid).set(userModle.toMap());
      } else {
        userModle = await getUserInfo(userCredential.user!.uid).first;
      }

      return right(userModle);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  Stream<UserModel> getUserInfo(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  void logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
