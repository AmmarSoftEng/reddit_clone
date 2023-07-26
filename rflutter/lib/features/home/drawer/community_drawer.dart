import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/common/error_text.dart';
import 'package:rflutter/core/common/loder.dart';
import 'package:rflutter/features/community/controller/community_controller.dart';
import 'package:rflutter/model/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityDrawer extends ConsumerWidget {
  const CommunityDrawer({super.key});

  void navigateToCreateCommunityScreen(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunityScreen(BuildContext context, Community community) {
    Routemaster.of(context).push('/community/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(communityControllerProvider);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text('Create a community'),
              leading: Icon(Icons.add),
              onTap: () {
                navigateToCreateCommunityScreen(context);
              },
            ),
            ref.watch(userCommunitProvider).when(
                  data: (communityList) {
                    return Expanded(
                      child: ListView.builder(
                          itemCount: communityList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final community = communityList[index];
                            return ListTile(
                                leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(community.banner)),
                                title: Text('r/${community.name}'),
                                onTap: () {
                                  navigateToCommunityScreen(context, community);
                                });
                          }),
                    );
                  },
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () => Loder(),
                ),
          ],
        ),
      ),
    );
  }
}
