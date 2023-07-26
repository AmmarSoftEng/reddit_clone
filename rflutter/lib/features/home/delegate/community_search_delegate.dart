// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/features/community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loder.dart';

class SearchCommunityDelegate extends SearchDelegate {
  WidgetRef ref;
  SearchCommunityDelegate({
    required this.ref,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.close)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
        data: (data) {
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final community = data[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(community.banner),
                  ),
                  title: Text('r/${community.name}'),
                  onTap: () {
                    navigateToCommunityScreen(context, community.name);
                  },
                );
              });
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loder());
  }

  void navigateToCommunityScreen(BuildContext context, String communityname) {
    Routemaster.of(context).push('/community/${communityname}');
  }
}
