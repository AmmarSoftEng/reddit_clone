import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rflutter/core/constants/firebase_constants.dart';
import 'package:rflutter/core/faliure.dart';
import 'package:rflutter/core/typedef.dart';
import 'package:rflutter/model/user_model.dart';

import '../../../model/post_model.dart';

final profileRepository = Provider((ref) {
  return UserProfileRepository(firebaseFirestore: ref.read(firestoreProvider));
});

class UserProfileRepository {
  FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firebaseFirestore})
      : _firestore = firebaseFirestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _post =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  Stream<List<Post>> userPost(String uid) {
    return _post
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karam': user.karma,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  
}
