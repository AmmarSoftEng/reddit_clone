import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/common/error_text.dart';
import 'package:rflutter/core/common/loder.dart';
import 'package:rflutter/core/constants/constants.dart';
import 'package:rflutter/core/util.dart';
import 'package:rflutter/features/community/controller/community_controller.dart';
import 'package:rflutter/model/community_model.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  String name;
  EditCommunityScreen({
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? file;

  void pickFiles() async {
    final res = await filepicker();
    if (res != null) {
      file = File(res.files.first.path!);
    }
  }

  void updateCommunity(
    Community community,
  ) {
    ref
        .read(communityControllerProvider.notifier)
        .updateCommunity(community, file, context);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (data) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Community'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () {
                    updateCommunity(data);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            pickFiles();
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(10),
                            dashPattern: [10, 4],
                            strokeCap: StrokeCap.round,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: file != null
                                  ? Image.file(file!)
                                  : data.banner.isEmpty ||
                                          Constants.bannerDefault == data.banner
                                      ? Center(
                                          child: Icon(
                                            Icons.camera_alt_outlined,
                                            size: 40,
                                          ),
                                        )
                                      : Image.network(data.banner),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                data.banner,
                              ),
                              radius: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loder());
  }
}
