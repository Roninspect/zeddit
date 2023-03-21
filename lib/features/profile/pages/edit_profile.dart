// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/profile/controller/profile_controller.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/utils.dart';
import '../../../core/constants/constants.dart';
import '../../../models/user_models.dart';

class EditProfile extends ConsumerStatefulWidget {
  String uid;
  late String name;
  EditProfile({
    super.key,
    required this.uid,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  TextEditingController? nameController;

  File? banner;
  File? profile;

  void pickBanner() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        banner = File(res.files.first.path!);
      });
    }
  }

  void pickProfile() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        profile = File(res.files.first.path!);
      });
    }
  }

  void save() {
    ref.read(profileControllerProvider.notifier).editProfile(
        profile: profile,
        banner: banner,
        profilename: nameController!.text,
        context: context);
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(profileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            appBar: AppBar(
              title: const Text("Edit profile"),
              actions: [
                TextButton(
                  onPressed: () => save(),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save"),
                ),
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DottedBorder(
                          strokeWidth: 2,
                          dashPattern: const [3, 3, 3, 3],
                          color: Colors.white,
                          child: GestureDetector(
                            onTap: () => pickBanner(),
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: banner != null
                                  ? Image.file(banner!)
                                  : user.banner.isEmpty ||
                                          user.banner == Constants.bannerDefault
                                      ? const Center(
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                          ),
                                        )
                                      : Image.network(user.banner),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 30,
                          child: GestureDetector(
                            onTap: () => pickProfile(),
                            child: SizedBox(
                              child: profile != null
                                  ? CircleAvatar(
                                      backgroundImage: FileImage(profile!),
                                      radius: 40,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                      radius: 40,
                                    ),
                            ),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(top: 20),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        hintText: "New Name", border: OutlineInputBorder()),
                  ),
                )
              ],
            ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const CircularProgressIndicator(),
        );
  }
}
