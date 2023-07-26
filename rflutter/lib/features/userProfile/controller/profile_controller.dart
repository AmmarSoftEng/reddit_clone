import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/enum/enum.dart';
import 'package:rflutter/core/provider/storage_repository.dart';
import 'package:rflutter/core/util.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/features/userProfile/repository/user_repository.dart';
import 'package:rflutter/model/user_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../model/post_model.dart';

final profilControllerProvider =
    StateNotifierProvider<ProfilController, bool>((ref) {
  return ProfilController(
      userProfileRepository: ref.read(profileRepository), ref: ref);
});

// stream provider to get user Posts
final userPost = StreamProvider.family((ref, String uid) =>
    ref.read(profilControllerProvider.notifier).getUserPost(uid));

class ProfilController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  Ref _ref;

  ProfilController(
      {required UserProfileRepository userProfileRepository, required Ref ref})
      : _userProfileRepository = userProfileRepository,
        _ref = ref,
        super(false);
  void editProfile(
      {required String name,
      required File? bannerFile,
      required File? avatarFile,
      required BuildContext context,
      required UserModel user}) async {
    state = true;

    if (bannerFile != null) {
      final res = await _ref
          .read(storageRepositoryprovidre)
          .storeFile(path: 'User/banner', id: user.uid, file: bannerFile);
      res.fold((l) => null, (r) => user = user.copyWith(banner: r));
    }

    if (avatarFile != null) {
      final res = await _ref
          .watch(storageRepositoryprovidre)
          .storeFile(path: 'User/avatar', id: user.uid, file: avatarFile);
      res.fold((l) => null, (r) => user = user.copyWith(profilePic: r));
    }
    user = user.copyWith(name: name);

    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.watch(userProvider.notifier).update((state) => user);
      return Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _userProfileRepository.userPost(uid);
  }

  void updateKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null, (r) {
      _ref.read(userProvider.notifier).update((state) => user);
    });
  }
}
