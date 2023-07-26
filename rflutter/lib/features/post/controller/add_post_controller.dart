import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/enum/enum.dart';
import 'package:rflutter/core/provider/storage_repository.dart';
import 'package:rflutter/core/util.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/features/post/repository/post_repository.dart';
import 'package:rflutter/features/userProfile/controller/profile_controller.dart';
import 'package:rflutter/model/comment.dart';
import 'package:rflutter/model/community_model.dart';
import 'package:rflutter/model/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

// Provider post Controller class
final postControllerProvider = StateNotifierProvider((ref) {
  return PostController(
      postRepository: ref.read(postRepositoryProvider), ref: ref);
});

// Stream Provider ot fetch post
final fetchPostStreamProvider =
    StreamProvider.family((ref, List<Community> communityes) {
  final postProvider = ref.watch(postControllerProvider.notifier);
  return postProvider.fetchPost(communityes);
});

// Stream Provider ot  fetch post by Id
final fetchPostByIDStreamProvider =
    StreamProvider.family((ref, String postUid) {
  final postProvider = ref.watch(postControllerProvider.notifier);
  return postProvider.getPostByName(postUid);
});

// Stream Provider ot  fetch Comment
final fetchCommentStreamProvider = StreamProvider.family((ref, String postUid) {
  final postProvider = ref.watch(postControllerProvider.notifier);
  return postProvider.getComment(postUid);
});

class PostController extends StateNotifier<bool> {
  Ref _ref;
  PostRepository _postRepository;

  PostController({required PostRepository postRepository, required Ref ref})
      : _postRepository = postRepository,
        _ref = ref,
        super(false);

  void postText(
      {required String title,
      required String discription,
      required Community selectedCommunity,
      required BuildContext context}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider);
    Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.banner,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user!.name,
      uid: user.uid,
      type: 'text',
      description: discription,
      createdAt: DateTime.now(),
      awards: [],
    );

    final res = await _postRepository.addPost(post);

    _ref
        .read(profilControllerProvider.notifier)
        .updateKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post succesfuly');
      Routemaster.of(context).pop();
    });
  }

  void postImage(
      {required String title,
      required File? postImage,
      required Community selectedCommunity,
      required BuildContext context}) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider);
    final res = await _ref.read(storageRepositoryprovidre).storeFile(
        path: "Post/${selectedCommunity.name}", id: postId, file: postImage!);

    res.fold((l) => showSnackBar(context, l.message), (r) async {
      Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.banner,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );
      final res = await _postRepository.addPost(post);

      _ref
          .read(profilControllerProvider.notifier)
          .updateKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Post succesfuly');
        Routemaster.of(context).pop();
      });
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider);
    final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user!.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);

    _ref
        .read(profilControllerProvider.notifier)
        .updateKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> fetchPost(List<Community> community) {
    if (community.isNotEmpty) {
      return _postRepository.fetchPost(community);
    }
    return Stream.value([]);
  }

  void deletePost(Post postId, BuildContext context) async {
    final res = await _postRepository.deletePost(postId);
    res.fold((l) => "Fail",
        (r) => showSnackBar(context, 'Post Deleted successfuly'));
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<Post> getPostByName(String postUid) {
    return _postRepository.getPostByName(postUid);
  }

  void addComment(Post post, String text, BuildContext context) async {
    final user = _ref.read(userProvider);
    final commentId = const Uuid().v1();
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.uid,
        username: user!.name,
        profilePic: user.profilePic);

    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, text), (r) => null);
  }

  Stream<List<Comment>> getComment(String postUid) {
    return _postRepository.getComment(postUid);
  }
}
