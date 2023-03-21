import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePostPage> {
  void navigateToPostType(String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create a Post"),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () => navigateToPostType('image'),
              child: SizedBox(
                height: 120,
                width: 120,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo),
                ),
              ),
            ),
            InkWell(
              onTap: () => navigateToPostType('text'),
              child: SizedBox(
                height: 120,
                width: 120,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.font_download_outlined),
                ),
              ),
            ),
            // InkWell(
            //   onTap: () => navigateToPostType('Link'),
            //   child: SizedBox(
            //     height: 120,
            //     width: 120,
            //     child: Card(
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Icon(Icons.link),
            //     ),
            //   ),
            // ),
          ],
        ));
  }
}
