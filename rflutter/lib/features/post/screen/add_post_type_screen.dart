import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rflutter/core/util.dart';
import 'package:rflutter/features/community/controller/community_controller.dart';
import 'package:rflutter/features/post/controller/add_post_controller.dart';
import 'package:rflutter/theme/pallete.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loder.dart';
import '../../../model/community_model.dart';

class PostType extends ConsumerStatefulWidget {
  String type;
  PostType({
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostTypeState();
}

class _PostTypeState extends ConsumerState<PostType> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;

  List<Community> communityes = [];

  Community? selectedCommunity;
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void slectBannerImage() async {
    final result = await filepicker();
    if (result != null) {
      setState(() {
        bannerFile = File(result.files.first.path!);
      });
    }
  }

  void post() {
    if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).postText(
          title: titleController.text.trim(),
          discription: descriptionController.text.trim(),
          selectedCommunity: selectedCommunity ?? communityes[0],
          context: context);
    } else if (widget.type == 'image' &&
        titleController.text.isNotEmpty &&
        bannerFile != null) {
      ref.read(postControllerProvider.notifier).postImage(
          title: titleController.text.trim(),
          postImage: bannerFile,
          selectedCommunity: selectedCommunity ?? communityes[0],
          context: context);
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        descriptionController.text.isEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context: context,
          title: titleController.text.trim(),
          selectedCommunity: selectedCommunity ?? communityes[0],
          link: linkController.text.trim());
    } else {
      showSnackBar(context, 'Please enter all the fields');
      print(widget.type +
          titleController.text +
          descriptionController.text +
          '${selectedCommunity}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: () {
              post();
            },
            child: Text('Share'),
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            textAlign: TextAlign.center,
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Enter Title here',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(18),
            ),
            maxLength: 30,
          ),
          SizedBox(
            height: 10,
          ),
          if (isTypeImage)
            GestureDetector(
              onTap: slectBannerImage,
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(10),
                dashPattern: [10, 4],
                strokeCap: StrokeCap.round,
                color: Pallete.darkModeAppTheme.textTheme.bodyText2!.color!,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: bannerFile != null
                      ? Image.file(bannerFile!)
                      : Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),
          if (isTypeText)
            TextField(
              textAlign: TextAlign.center,
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter Description here',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
              ),
              maxLines: 5,
            ),
          if (isTypeLink)
            TextField(
              textAlign: TextAlign.center,
              controller: linkController,
              decoration: const InputDecoration(
                hintText: 'Enter link here',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
              ),
            ),
          SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text('Select  Community'),
          ),
          ref.watch(userCommunitProvider).when(
              data: (data) {
                communityes = data;
                if (data.isEmpty) {
                  return SizedBox();
                }
                return DropdownButton(
                    value: selectedCommunity ?? data[0],
                    items: data
                        .map((e) => DropdownMenuItem(
                              child: Text(e.name),
                              value: e,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCommunity = value as Community;
                      });
                    });
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => Loder()),
        ],
      ),
    );
  }
}
