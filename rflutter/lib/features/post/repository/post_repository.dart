import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rflutter/core/constants/firebase_constants.dart';
import 'package:rflutter/core/faliure.dart';
import 'package:rflutter/core/typedef.dart';
import 'package:rflutter/model/post_model.dart';

import '../../../model/comment.dart';
import '../../../model/community_model.dart';

final postRepositoryProvider =
    Provider((ref) => PostRepository(firestore: ref.read(firestoreProvider)));

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _post =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _comment =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(Post post) async {
    return right(await _post.doc(post.uid).set(post.toMap()));
  }

  Stream<List<Post>> fetchPost(List<Community> communityes) {
    return _post
        .where('communityName',
            whereIn: communityes.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
    //     .map((event) {
    //   List<Post> postList = [];
    //   for (var i in event.docs) {
    //     postList.add(Post.fromMap(i.data() as Map<String, dynamic>));
    //   }
    //   return postList;
    // });
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(
        await _post.doc(post.uid).delete(),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _post.doc(post.uid).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.upvotes.contains(userId)) {
      _post.doc(post.uid).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.uid).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _post.doc(post.uid).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.downvotes.contains(userId)) {
      _post.doc(post.uid).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _post.doc(post.uid).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<Post> getPostByName(String postUid) {
    return _post
        .doc(postUid)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comment.doc(comment.id).set(comment.toMap());
      return right(
        _post.doc(comment.postId).update(
          {
            'commentCount': FieldValue.increment(1),
          },
        ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failuer(message: e.toString()));
    }
  }

  Stream<List<Comment>> getComment(String postId) {
    return _comment
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }
}
