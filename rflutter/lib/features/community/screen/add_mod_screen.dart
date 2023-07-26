import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/features/community/controller/community_controller.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loder.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  String name;
  AddModsScreen({
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int ctr = 0;

  void addInUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeInUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                saveMods();
              },
              icon: Icon(Icons.done)),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) {
              return ListView.builder(
                  itemCount: community.members.length,
                  itemBuilder: (context, index) {
                    if (ctr == 0) {
                      for (var i = 0; i < community.mods.length; i++) {
                        uids.add(community.mods[i]);
                      }
                      ctr++;
                    }

                    final userUid = community.members[index];
                    return ref.watch(getUserModleProvider(userUid)).when(
                          data: (user) {
                            // if (community.mods.contains(user.uid)) {
                            //   uids.add(user.uid);
                            //   ctr++;
                            // }

                            return CheckboxListTile(
                              value: uids.contains(user.uid),
                              onChanged: (val) {
                                if (val!) {
                                  addInUids(user.uid);
                                } else {
                                  removeInUids(user.uid);
                                }
                              },
                              title: Text(user.name),
                            );
                          },
                          error: (error, staskTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => Loder(),
                        );
                  });
            },
            error: (error, staskTrace) => ErrorText(error: error.toString()),
            loading: () => Loder(),
          ),
    );
  }
}
