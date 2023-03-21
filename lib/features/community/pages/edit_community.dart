import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/utils.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';

class EditCommunity extends ConsumerStatefulWidget {
  final String name;
  const EditCommunity({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditCommunityState();
}

class _EditCommunityState extends ConsumerState<EditCommunity> {
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

  void save(CommunityModel communityModel) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        name: widget.name,
        communityModel: communityModel,
        profile: profile,
        banner: banner,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) => Scaffold(
            appBar: AppBar(
              title: const Text("Edit Community"),
              actions: [
                TextButton(
                  onPressed: () async {
                    return save(community);
                  },
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
                  child: Stack(children: [
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
                                : community.banner.isEmpty ||
                                        community.banner ==
                                            Constants.bannerDefault
                                    ? const Center(
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                        ),
                                      )
                                    : Image.network(community.banner),
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
                                        NetworkImage(community.avatar),
                                    radius: 40,
                                  ),
                          ),
                        ))
                  ]),
                )
              ],
            ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const CircularProgressIndicator(),
        );
  }
}
