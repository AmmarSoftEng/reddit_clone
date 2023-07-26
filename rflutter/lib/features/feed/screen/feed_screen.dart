import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/common/post_card.dart';

import 'package:rflutter/features/community/controller/community_controller.dart';
import 'package:rflutter/features/post/controller/add_post_controller.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loder.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitProvider).when(
        data: (data) => ref.watch(fetchPostStreamProvider(data)).when(
            data: (data) {
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final post = data[index];
                    return PostCard(post: post);
                  });
            },
            error: (error, stackTrace) {
              return ErrorText(error: error.toString());
            },
            loading: () => Loder()),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loder());
  }
}
