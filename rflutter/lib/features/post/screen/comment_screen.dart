import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/common/post_card.dart';
import 'package:rflutter/features/post/controller/add_post_controller.dart';
import 'package:rflutter/model/post_model.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loder.dart';
import '../widget/comment_card.dart';

class Comment extends ConsumerStatefulWidget {
  final String postId;
  Comment({
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentState();
}

class _CommentState extends ConsumerState<Comment> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    ref
        .read(postControllerProvider.notifier)
        .addComment(post, commentController.text, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(fetchPostByIDStreamProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    onSubmitted: (value) {
                      addComment(data);
                    },
                    controller: commentController,
                    decoration: InputDecoration(
                        hintText: 'What are your thougths?',
                        filled: true,
                        border: InputBorder.none),
                  ),
                  ref.watch(fetchCommentStreamProvider(widget.postId)).when(
                        data: (data) {
                          return Expanded(
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final comment = data[index];
                                  return CommentCard(comment: comment);
                                }),
                          );
                        },
                        error: (error, staskTrace) {
                          print(error);
                          return ErrorText(error: error.toString());
                        },
                        loading: () => Loder(),
                      ),
                ],
              );
            },
            error: (error, staskTrace) => ErrorText(error: error.toString()),
            loading: () => Loder(),
          ),
    );
    ;
  }
}
