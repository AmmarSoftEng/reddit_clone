import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter/core/util.dart';

import 'package:rflutter/features/auth/controller/auth_controller.dart';
import 'package:rflutter/features/userProfile/controller/profile_controller.dart';
import 'package:rflutter/model/user_model.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loder.dart';
import '../../../core/constants/constants.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  String uid;
  EditProfileScreen({
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    nameController.dispose();
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

  void slectProfilemage() async {
    final result = await filepicker();
    if (result != null) {
      setState(() {
        profileFile = File(result.files.first.path!);
      });
    }
  }

  void save(UserModel userModel) {
    ref.read(profilControllerProvider.notifier).editProfile(
        name: nameController.text,
        bannerFile: bannerFile,
        avatarFile: profileFile,
        context: context,
        user: userModel);
  }

  @override
  Widget build(BuildContext context) {
    final isLoaded = ref.watch(profilControllerProvider);
    return ref.watch(getUserModleProvider(widget.uid)).when(
        data: (user) => Scaffold(
              appBar: AppBar(
                title: Text('Edit Profile'),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: () => save(user),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: isLoaded
                  ? Loder()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: slectBannerImage,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(10),
                                    dashPattern: [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: Colors.black,
                                    child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : user.banner.isEmpty ||
                                                  user.banner ==
                                                      Constants.bannerDefault
                                              ? Center(
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ),
                                                )
                                              : Image.network(user.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                      onTap: slectProfilemage,
                                      child: profileFile != null
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  FileImage(profileFile!),
                                              radius: 32,
                                            )
                                          : CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(user.profilePic),
                                              radius: 32,
                                            )),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(18),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
        error: (error, staskTrace) => ErrorText(error: error.toString()),
        loading: () => Loder());
  }
}
