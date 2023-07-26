import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rflutter/core/constants/constants.dart';
import 'package:rflutter/core/faliure.dart';
import 'package:rflutter/core/provider/storage_repository.dart';
import 'package:rflutter/core/util.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/features/community/repository/community_repository.dart';
import 'package:rflutter/model/community_model.dart';
import 'package:routemaster/routemaster.dart';

// Community Controller Provider
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepository: ref.read(communityRepositoryProvider), ref: ref);
});

// get User Community Stream provider

final userCommunitProvider = StreamProvider((ref) {
  return ref.read(communityControllerProvider.notifier).getCommunityList();
});

// Stream provider to get community data by name
final getCommunityByNameProvider =
    StreamProvider.family((ref, String community) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(community);
});

// Stream provider to search community
final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.read(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final Ref _ref;
  final CommunityRepository _communityRepository;
  CommunityController(
      {required CommunityRepository communityRepository, required Ref ref})
      : _communityRepository = communityRepository,
        _ref = ref,
        super(false);

  void createCommunity(String communityName, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
        id: communityName,
        name: communityName,
        banner: Constants.bannerDefault,
        avatar: Constants.bannerDefault,
        members: [uid],
        mods: [uid]);

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => Failuer(message: l.message), (r) {
      showSnackBar(context, "Community created Successfully");
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getCommunityList() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getCommunity(uid);
  }

  Stream<Community> getCommunityByName(String community) {
    return _communityRepository.getCommunityByName(community);
  }

  void updateCommunity(
      Community community, File? bannerfile, BuildContext context) async {
    if (bannerfile != null) {
      final res = await _ref.read(storageRepositoryprovidre).storeFile(
          path: 'communities/banner', id: community.name, file: bannerfile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(banner: r));
    }

    final res = await _communityRepository.editCommunity(community);
    res.fold((l) => null, (r) {
      return Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failuer, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold((l) => Failuer(message: l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, "Successfully leave the community");
      } else {
        showSnackBar(context, "Successfully join the community");
      }
    });
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      Routemaster.of(context).pop();
    });
  }
}
