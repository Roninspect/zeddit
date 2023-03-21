// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/create_post/controller/post_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/palette.dart';

import '../../../core/common/utils.dart';

class AddPostType extends ConsumerStatefulWidget {
  String type;
  AddPostType({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostTypeState();
}

class _AddPostTypeState extends ConsumerState<AddPostType> {
  TextEditingController textController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // List<CommunityModel> communities = [];
  CommunityModel? selectedCommuniy;

  File? postImage;

  void pickBanner() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        postImage = File(res.files.first.path!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    descriptionController.dispose();
  }

  void addPost() {
    if (widget.type == 'text' &&
        textController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedCommuniy != null) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: textController.text,
          description: descriptionController.text,
          selectedCommunity: selectedCommuniy!);
    } else if (widget.type == 'image' &&
        textController.text.isNotEmpty &&
        postImage != null &&
        selectedCommuniy != null) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context: context,
          title: textController.text,
          selectedCommunity: selectedCommuniy!,
          file: postImage!);
    } else {
      showsnackBar(context, "please enter all field");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(postControllerProvider);
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    // final isTypeLink = widget.type == 'Link';

    final currentTheme = ref.watch(themeProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('add a ${widget.type} post '),
        actions: [
          TextButton(
            onPressed: () => addPost(),
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Share"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              child: TextField(
                maxLength: 30,
                expands: true,
                maxLines: null,
                controller: textController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Interesting Title...",
                  filled: true,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isTypeImage)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DottedBorder(
                  strokeWidth: 2,
                  dashPattern: const [3, 3, 3, 3],
                  color: currentTheme.textTheme.bodySmall!.color!,
                  child: GestureDetector(
                    onTap: () => pickBanner(),
                    child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: postImage != null
                            ? Image.file(postImage!)
                            : const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                ),
                              )),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (isTypeText)
              SizedBox(
                height: 200,
                child: TextField(
                  expands: true,
                  maxLines: null,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Interesting Description...",
                    filled: true,
                    isDense: true,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Select Community",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ref.watch(userCommunityProvider).when(
                  data: (data) {
                    // communities = data;
                    if (data.isEmpty) {
                      return const SizedBox();
                    }
                    return DropdownButton<CommunityModel>(
                      menuMaxHeight: 300,
                      value: selectedCommuniy,
                      items: (data as List<CommunityModel>)
                          .map(
                            (e) => DropdownMenuItem<CommunityModel>(
                              value: e,
                              child: SizedBox(
                                height: 60,
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: Image.network(
                                      e.avatar,
                                      height: 60,
                                    ),
                                    title: Text(e.name),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCommuniy = val;
                        });
                      },
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const CircularProgressIndicator(),
                )
          ],
        ),
      ),
    );
  }
}
