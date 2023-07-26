import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rflutter/core/constants/firebase_constants.dart';
import 'package:rflutter/core/faliure.dart';
import 'package:rflutter/core/typedef.dart';
import 'package:rflutter/model/community_model.dart';

final communityRepositoryProvider = Provider(
  (ref) => CommunityRepository(
    firebaseFirestore: ref.read(firestoreProvider),
  ),
);

class CommunityRepository {
  final FirebaseFirestore _firebaseFirestore;
  CommunityRepository({required FirebaseFirestore firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _community =>
      _firebaseFirestore.collection(FirebaseConstants.communitiesCollection);

  FutureVoid createCommunity(Community communityName) async {
    try {
      final community = await _community.doc(communityName.name).get();
      if (community.exists) {
        throw 'Communoty with the same already exists';
      }

      return right(
          _community.doc(communityName.name).set(communityName.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  Stream<List<Community>> getCommunity(String uid) {
    return _community
        .where('members', arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> list = [];
      for (var i in event.docs) {
        list.add(Community.fromMap(i.data() as Map<String, dynamic>));
      }
      return list;
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _community.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(
          await _community.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _community
        .where("name",
            isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
            isLessThan: query.isEmpty
                ? null
                : query.substring(0, query.length - 1) +
                    String.fromCharCode(query.codeUnitAt(query.length - 1) + 1))
        .snapshots()
        .map((event) {
      List<Community> list = [];
      for (var i in event.docs) {
        list.add(Community.fromMap(i.data() as Map<String, dynamic>));
      }
      return list;
    });
  }

  FutureVoid joinCommunity(String communityName, String uid) async {
    try {
      return right(await _community.doc(communityName).update({
        'members': FieldValue.arrayUnion([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String uid) async {
    try {
      return right(await _community.doc(communityName).update({
        'members': FieldValue.arrayRemove([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(await _community.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }
}
